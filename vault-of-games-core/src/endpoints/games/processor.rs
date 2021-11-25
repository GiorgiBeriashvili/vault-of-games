use anyhow::Result;
use axum::{
    extract::{Extension, Path},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use chrono::Utc;
use jwt_simple::prelude::{JWTClaims, NoCustomClaims};
use sqlx::{query, query_as, sqlite::SqliteQueryResult};
use uuid::Uuid;

use crate::{
    database::DatabaseConnectionPool,
    endpoints::games::entities::{Categories, Status},
    error::ProcessorError,
};

use super::entities::{
    payloads::{GameCreatePayload, GameUpdatePayload},
    Game,
};

#[derive(Default)]
pub struct GamesProcessor;

impl GamesProcessor {
    pub async fn create(
        Json(payload): Json<GameCreatePayload>,
        Extension(claims): Extension<JWTClaims<NoCustomClaims>>,
        Extension(pool): Extension<DatabaseConnectionPool>,
    ) -> Result<impl IntoResponse, ProcessorError> {
        let game = Game::new(
            Uuid::new_v4().to_string(),
            claims.subject.unwrap(),
            payload.title,
            payload.image_url,
            payload.status,
            payload.rating,
            Some(payload.categories.into()),
            payload.note,
            Utc::now().to_string(),
            None,
        );

        query!(
            "
            INSERT INTO games (id, user_id, title, image_url, status, rating, note, created_at, updated_at)
            VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9);
            ",
            game.id,
            game.user_id,
            game.title,
            game.image_url,
            game.status,
            game.rating,
            game.note,
            game.created_at,
            game.updated_at,
        )
        .execute(&pool)
        .await?;

        if let Some(categories) = &game.categories {
            for category in categories.content.iter() {
                let record = query!(
                    "
                    SELECT id
                    FROM categories
                    WHERE name = ?;
                    ",
                    category
                )
                .fetch_optional(&pool)
                .await?;

                let category_id = match record {
                    Some(record) => record.id,
                    None => Some(Uuid::new_v4().to_string()),
                };

                query!(
                    "
                    INSERT OR IGNORE INTO categories (id, name)
                    VALUES (?1, ?2);
                    ",
                    category_id,
                    category,
                )
                .execute(&pool)
                .await?;

                query!(
                    "
                    INSERT INTO games_categories (game_id, category_id)
                    VALUES (?1, ?2);
                    ",
                    game.id,
                    category_id,
                )
                .execute(&pool)
                .await?;
            }
        }

        Ok((StatusCode::CREATED, Json(game)))
    }

    pub async fn read(
        Path(id): Path<String>,
        Extension(claims): Extension<JWTClaims<NoCustomClaims>>,
        Extension(pool): Extension<DatabaseConnectionPool>,
    ) -> Result<impl IntoResponse, ProcessorError> {
        let user_id = claims.subject.unwrap();

        let game = query_as!(
            Game,
            r#"
            SELECT g.id as "id!",
                g.user_id as "user_id!",
                g.title as "title!",
                g.image_url as "image_url?",
                g.status as "status?: Status",
                g.rating as "rating?: u8",
                json_group_array(json_quote(c.name)) as "categories?: Categories",
                g.note as "note?",
                g.created_at as "created_at!: String",
                g.updated_at as "updated_at?: String"
            FROM games g
                    JOIN games_categories gc on g.id = gc.game_id
                    JOIN categories c on c.id = gc.category_id
            WHERE g.id = ?1 AND g.user_id = ?2;
            "#,
            id,
            user_id,
        )
        .fetch_one(&pool)
        .await?;

        if game.id.is_empty() {
            return Err(ProcessorError::DatabaseError(sqlx::Error::RowNotFound));
        }

        Ok(Json(game))
    }

    pub async fn read_all(
        Extension(claims): Extension<JWTClaims<NoCustomClaims>>,
        Extension(pool): Extension<DatabaseConnectionPool>,
    ) -> Result<impl IntoResponse, ProcessorError> {
        let user_id = claims.subject.unwrap();

        let games = query_as!(
            Game,
            r#"
            SELECT g.id as "id!",
                g.user_id as "user_id!",
                g.title as "title!",
                g.image_url as "image_url?",
                g.status as "status?: Status",
                g.rating as "rating?: u8",
                json_group_array(json_quote(c.name)) as "categories?: Categories",
                g.note as "note?",
                g.created_at as "created_at!: String",
                g.updated_at as "updated_at?: String"
            FROM games g
                    JOIN games_categories gc on g.id = gc.game_id
                    JOIN categories c on c.id = gc.category_id
            WHERE user_id = ?
            GROUP BY g.id, g.title, g.image_url, g.status, g.rating, g.note, g.created_at, g.updated_at
            ORDER BY g.created_at DESC;
            "#,
            user_id,
        )
        .fetch_all(&pool)
        .await?;

        Ok(Json(games))
    }

    pub async fn update(
        Path(id): Path<String>,
        Json(payload): Json<GameUpdatePayload>,
        Extension(claims): Extension<JWTClaims<NoCustomClaims>>,
        Extension(pool): Extension<DatabaseConnectionPool>,
    ) -> Result<impl IntoResponse, ProcessorError> {
        let user_id = claims.subject.unwrap();

        let game = query!(
            "
            UPDATE games
            SET title      = ?1,
                image_url  = ?2,
                status     = ?3,
                rating     = ?4,
                note       = ?5,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ?6 AND user_id = ?7;
            ",
            payload.title,
            payload.image_url,
            payload.status,
            payload.rating,
            payload.note,
            id,
            user_id,
        )
        .execute(&pool)
        .await?;

        if game.rows_affected() == 0 {
            return Err(ProcessorError::DatabaseError(sqlx::Error::RowNotFound));
        }

        if let Some(categories) = payload.categories {
            query!(
                "
                DELETE
                FROM games_categories
                WHERE game_id = ?;
                ",
                id,
            )
            .execute(&pool)
            .await?;

            for category in categories {
                let record = query!(
                    "
                    SELECT id
                    FROM categories
                    WHERE name = ?;
                    ",
                    category
                )
                .fetch_optional(&pool)
                .await?;

                if let Some(record) = record {
                    query!(
                        "
                        INSERT INTO games_categories (game_id, category_id)
                        VALUES (?1, ?2);
                        ",
                        id,
                        record.id,
                    )
                    .execute(&pool)
                    .await?;
                } else {
                    let category_id = Uuid::new_v4().to_string();

                    query!(
                        "
                        INSERT OR IGNORE INTO categories (id, name)
                        VALUES (?1, ?2);
                        ",
                        category_id,
                        category,
                    )
                    .execute(&pool)
                    .await?;

                    query!(
                        "
                        INSERT INTO games_categories (game_id, category_id)
                        VALUES (?1, ?2);
                        ",
                        id,
                        category_id,
                    )
                    .execute(&pool)
                    .await?;
                }
            }
        }

        Ok(StatusCode::OK)
    }

    pub async fn delete(
        Path(id): Path<String>,
        Extension(claims): Extension<JWTClaims<NoCustomClaims>>,
        Extension(pool): Extension<DatabaseConnectionPool>,
    ) -> Result<impl IntoResponse, ProcessorError> {
        let user_id = claims.subject.unwrap();

        let game: SqliteQueryResult = query!(
            "
            DELETE
            FROM games
            WHERE id = ?1 AND user_id = ?2;
            ",
            id,
            user_id,
        )
        .execute(&pool)
        .await?;

        if game.rows_affected() == 0 {
            return Err(ProcessorError::DatabaseError(sqlx::Error::RowNotFound));
        }

        Ok(StatusCode::NO_CONTENT)
    }
}
