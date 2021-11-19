pub mod payloads;

use serde::Serialize;
use uuid::Uuid;

use self::payloads::Update;

#[derive(Clone, Serialize)]
pub struct User {
    pub id: Uuid,
    pub username: String,
    pub password: String,
    pub created_at: String,
    pub updated_at: Option<String>,
}

impl User {
    pub fn new(
        id: Uuid,
        username: String,
        password: String,
        created_at: String,
        updated_at: Option<String>,
    ) -> Self {
        Self {
            id,
            username,
            password,
            created_at,
            updated_at,
        }
    }

    pub fn update(&mut self, payload: Update) {
        self.password = payload.password;
    }
}
