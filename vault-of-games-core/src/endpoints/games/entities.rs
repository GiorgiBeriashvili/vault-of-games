use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Clone, Serialize)]
pub struct Game {
    pub id: Uuid,
    pub title: String,
}

impl Game {
    pub fn new(id: Uuid, title: String) -> Self {
        Game { id, title }
    }
}

#[derive(Deserialize)]
pub struct CreateGame {
    pub title: String,
}

#[derive(Deserialize)]
pub struct UpdateGame {
    pub title: String,
}
