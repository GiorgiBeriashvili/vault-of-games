use axum::{
    extract::{Extension, Path},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use chrono::Utc;
use uuid::Uuid;

use crate::{database::Database, processor::Processor};

use super::entities::{
    payloads::{Create, Update},
    Game,
};

#[derive(Default)]
pub struct GamesProcessor;

impl Processor for GamesProcessor {}

impl GamesProcessor {
    pub async fn create(
        Json(payload): Json<Create>,
        Extension(database): Extension<Database<Uuid, Game>>,
    ) -> Result<impl IntoResponse, StatusCode> {
        let game = Game::new(
            Uuid::new_v4(),
            payload.title,
            payload.image_url,
            payload.status,
            payload.rating,
            payload.categories,
            payload.note,
            Utc::now().to_string(),
            None,
        );

        database
            .write()
            .map_err(Self::error)?
            .insert(game.id, game.clone());

        Ok((StatusCode::CREATED, Json(game)))
    }

    pub async fn read(
        Path(id): Path<Uuid>,
        Extension(database): Extension<Database<Uuid, Game>>,
    ) -> Result<impl IntoResponse, StatusCode> {
        let game = database
            .read()
            .map_err(Self::error)?
            .get(&id)
            .cloned()
            .ok_or(StatusCode::NOT_FOUND)?;

        Ok(Json(game))
    }

    pub async fn read_all(
        Extension(database): Extension<Database<Uuid, Game>>,
    ) -> Result<impl IntoResponse, StatusCode> {
        let games = database
            .read()
            .map_err(Self::error)?
            .values()
            .cloned()
            .collect::<Vec<_>>();

        Ok(Json(games))
    }

    pub async fn update(
        Path(id): Path<Uuid>,
        Json(payload): Json<Update>,
        Extension(database): Extension<Database<Uuid, Game>>,
    ) -> Result<impl IntoResponse, StatusCode> {
        let mut game = database
            .read()
            .map_err(Self::error)?
            .get(&id)
            .cloned()
            .ok_or(StatusCode::NOT_FOUND)?;

        game.update(payload);

        if database
            .write()
            .map_err(Self::error)?
            .insert(game.id, game.clone())
            .is_none()
        {
            Ok(Json(game))
        } else {
            Err(StatusCode::INTERNAL_SERVER_ERROR)
        }
    }

    pub async fn delete(
        Path(id): Path<Uuid>,
        Extension(database): Extension<Database<Uuid, Game>>,
    ) -> Result<impl IntoResponse, StatusCode> {
        if database.write().map_err(Self::error)?.remove(&id).is_some() {
            Ok(StatusCode::NO_CONTENT)
        } else {
            Err(StatusCode::NOT_FOUND)
        }
    }
}
