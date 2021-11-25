use anyhow::Result;
use axum::{
    extract::{Extension, Path},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use chrono::Utc;
use jwt_simple::prelude::{Claims, Duration, EdDSAKeyPairLike};
use rand::Rng;
use sqlx::{query, query_as, sqlite::SqliteQueryResult};
use uuid::Uuid;

use crate::{
    authentication::{error::AuthenticationError, keys::LAZY_KEYPAIR, AuthenticationResponse},
    database::DatabaseConnectionPool,
    error::ProcessorError,
};

use super::entities::{
    payloads::{UserAuthenticationPayload, UserUpdatePayload},
    User,
};

#[derive(Default)]
pub struct UsersProcessor;

impl UsersProcessor {
    pub async fn sign_in(
        Json(payload): Json<UserAuthenticationPayload>,
        Extension(pool): Extension<DatabaseConnectionPool>,
    ) -> Result<impl IntoResponse, ProcessorError> {
        if payload.username.is_empty() || payload.password.is_empty() {
            return Err(ProcessorError::AuthenticationError(
                AuthenticationError::MissingCredentials,
            ));
        }

        let user = query!(
            "
            SELECT id, password
            FROM users
            WHERE username = ?;
            ",
            payload.username
        )
        .fetch_optional(&pool)
        .await?;

        if let Some(user) = user {
            if !argon2::verify_encoded(user.password.as_str(), payload.password.as_bytes())? {
                return Err(ProcessorError::AuthenticationError(
                    AuthenticationError::WrongCredentials,
                ));
            }

            let claims = Claims::create(Duration::from_mins(15)).with_subject(user.id.unwrap());

            let token = LAZY_KEYPAIR.private_key.sign(claims)?;

            Ok(Json(AuthenticationResponse::new(token)))
        } else {
            Err(ProcessorError::DatabaseError(sqlx::Error::RowNotFound))
        }
    }

    pub async fn sign_up(
        Json(payload): Json<UserAuthenticationPayload>,
        Extension(pool): Extension<DatabaseConnectionPool>,
    ) -> Result<impl IntoResponse, ProcessorError> {
        let password_hash = argon2::hash_encoded(
            payload.password.as_bytes(),
            &rand::thread_rng().gen::<[u8; 32]>(),
            &argon2::Config::default(),
        )?;

        let user = User::new(
            Uuid::new_v4().to_string(),
            payload.username,
            password_hash,
            Utc::now().to_string(),
            None,
        );

        query!(
            "
            INSERT INTO users (id, username, password, created_at, updated_at)
            VALUES (?1, ?2, ?3, ?4, ?5);
            ",
            user.id,
            user.username,
            user.password,
            user.created_at,
            user.updated_at,
        )
        .execute(&pool)
        .await?;

        Ok((StatusCode::CREATED, Json(user)))
    }

    pub async fn read(
        Path(id): Path<String>,
        Extension(pool): Extension<DatabaseConnectionPool>,
    ) -> Result<impl IntoResponse, ProcessorError> {
        let user = query_as!(
            User,
            r#"
            SELECT id as "id!",
                username as "username!",
                password as "password!",
                created_at as "created_at!: String",
                updated_at as "updated_at?: String"
            FROM users
            WHERE id = ?;
            "#,
            id
        )
        .fetch_one(&pool)
        .await?;

        if user.id.is_empty() {
            return Err(ProcessorError::DatabaseError(sqlx::Error::RowNotFound));
        }

        Ok(Json(user))
    }

    pub async fn update(
        Path(id): Path<String>,
        Json(payload): Json<UserUpdatePayload>,
        Extension(pool): Extension<DatabaseConnectionPool>,
    ) -> Result<impl IntoResponse, ProcessorError> {
        let password_hash = argon2::hash_encoded(
            payload.password.as_bytes(),
            &rand::thread_rng().gen::<[u8; 32]>(),
            &argon2::Config::default(),
        )?;

        let user = query!(
            "
            UPDATE users
            SET username   = ?1,
                password   = ?2,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ?3;
            ",
            payload.username,
            password_hash,
            id,
        )
        .execute(&pool)
        .await?;

        if user.rows_affected() == 0 {
            return Err(ProcessorError::DatabaseError(sqlx::Error::RowNotFound));
        }

        Ok(())
    }

    pub async fn delete(
        Path(id): Path<String>,
        Extension(pool): Extension<DatabaseConnectionPool>,
    ) -> Result<impl IntoResponse, ProcessorError> {
        let user: SqliteQueryResult = query!(
            "
            DELETE
            FROM users
            where id = ?;
            ",
            id
        )
        .execute(&pool)
        .await?;

        if user.rows_affected() == 0 {
            return Err(ProcessorError::DatabaseError(sqlx::Error::RowNotFound));
        }

        Ok(StatusCode::NO_CONTENT)
    }
}
