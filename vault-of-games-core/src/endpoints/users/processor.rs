use axum::{
    extract::{Extension, Path},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use chrono::Utc;
use jwt_simple::prelude::{Claims, Duration, EdDSAKeyPairLike};
use uuid::Uuid;

use crate::{
    authentication::{error::AuthenticationError, keys::LAZY_KEYPAIR, AuthenticationResponse},
    database::Database,
    processor::Processor,
};

use super::entities::{
    payloads::{Authenticate, Update},
    User,
};

#[derive(Default)]
pub struct UsersProcessor;

impl Processor for UsersProcessor {}

impl UsersProcessor {
    pub async fn sign_in(
        Json(payload): Json<Authenticate>,
        Extension(database): Extension<Database<Uuid, User>>,
    ) -> impl IntoResponse {
        if payload.username.is_empty() || payload.password.is_empty() {
            return Err(AuthenticationError::MissingCredentials);
        }

        let user = database
            .read()
            .unwrap()
            .values()
            .find(|user| user.username == payload.username)
            .cloned()
            .ok_or(StatusCode::NOT_FOUND);

        if user.is_err() || user.clone().unwrap().password != payload.password {
            return Err(AuthenticationError::WrongCredentials);
        }

        let claims = Claims::create(Duration::from_secs(30)).with_subject(user.unwrap().id);

        let token = LAZY_KEYPAIR.private_key.sign(claims)?;

        Ok(Json(AuthenticationResponse::new(token)))
    }

    pub async fn sign_up(
        Json(payload): Json<Authenticate>,
        Extension(database): Extension<Database<Uuid, User>>,
    ) -> Result<impl IntoResponse, StatusCode> {
        let user = User::new(
            Uuid::new_v4(),
            payload.username,
            payload.password,
            Utc::now().to_string(),
            None,
        );

        database
            .write()
            .map_err(Self::error)?
            .insert(user.id, user.clone());

        Ok((StatusCode::CREATED, Json(user)))
    }

    pub async fn read(
        Path(id): Path<Uuid>,
        Extension(database): Extension<Database<Uuid, User>>,
    ) -> Result<impl IntoResponse, StatusCode> {
        let user = database
            .read()
            .map_err(Self::error)?
            .get(&id)
            .cloned()
            .ok_or(StatusCode::NOT_FOUND)?;

        Ok(Json(user))
    }

    pub async fn update(
        Path(id): Path<Uuid>,
        Json(payload): Json<Update>,
        Extension(database): Extension<Database<Uuid, User>>,
    ) -> Result<impl IntoResponse, StatusCode> {
        let mut user = database
            .read()
            .map_err(Self::error)?
            .get(&id)
            .cloned()
            .ok_or(StatusCode::NOT_FOUND)?;

        user.update(payload);

        if database
            .write()
            .map_err(Self::error)?
            .insert(user.id, user.clone())
            .is_none()
        {
            Ok(Json(user))
        } else {
            Err(StatusCode::INTERNAL_SERVER_ERROR)
        }
    }

    pub async fn delete(
        Path(id): Path<Uuid>,
        Extension(database): Extension<Database<Uuid, User>>,
    ) -> Result<impl IntoResponse, StatusCode> {
        if database.write().map_err(Self::error)?.remove(&id).is_some() {
            Ok(StatusCode::NO_CONTENT)
        } else {
            Err(StatusCode::NOT_FOUND)
        }
    }
}
