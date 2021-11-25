pub mod payloads;

use serde::Serialize;

#[derive(Clone, Debug, Serialize)]
pub struct User {
    pub id: String,
    pub username: String,
    pub password: String,
    pub created_at: String,
    pub updated_at: Option<String>,
}

impl User {
    pub fn new(
        id: String,
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
}
