use axum::{
    extract::{Extension, Path},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use uuid::Uuid;

use crate::server::Database;

use super::entities::{CreateGame, Game, UpdateGame};

#[derive(Default)]
pub struct Processor;

impl Processor {
    pub async fn create(
        Json(payload): Json<CreateGame>,
        Extension(database): Extension<Database>,
    ) -> impl IntoResponse {
        let game = Game::new(
            Uuid::new_v4(),
            payload.title,
            payload.image_url,
            payload.status,
            payload.rating,
            payload.categories,
            payload.note,
        );

        database.write().unwrap().insert(game.id, game.clone());

        (StatusCode::CREATED, Json(game))
    }

    pub async fn read(
        Path(id): Path<Uuid>,
        Extension(database): Extension<Database>,
    ) -> Result<impl IntoResponse, StatusCode> {
        let game = database
            .read()
            .unwrap()
            .get(&id)
            .cloned()
            .ok_or(StatusCode::NOT_FOUND)?;

        Ok(Json(game))
    }

    pub async fn read_all(Extension(database): Extension<Database>) -> impl IntoResponse {
        let games = database.read().unwrap();

        let games = games.values().cloned().collect::<Vec<_>>();

        Json(games)
    }

    pub async fn update(
        Path(id): Path<Uuid>,
        Json(payload): Json<UpdateGame>,
        Extension(database): Extension<Database>,
    ) -> Result<impl IntoResponse, StatusCode> {
        let mut game = database
            .read()
            .unwrap()
            .get(&id)
            .cloned()
            .ok_or(StatusCode::NOT_FOUND)?;

        game.update(payload);

        database
            .write()
            .unwrap()
            .insert(game.id, game.clone())
            .unwrap();

        Ok(Json(game))
    }

    pub async fn delete(
        Path(id): Path<Uuid>,
        Extension(database): Extension<Database>,
    ) -> impl IntoResponse {
        if database.write().unwrap().remove(&id).is_some() {
            StatusCode::NO_CONTENT
        } else {
            StatusCode::NOT_FOUND
        }
    }
}
