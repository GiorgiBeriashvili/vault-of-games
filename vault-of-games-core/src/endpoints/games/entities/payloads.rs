use serde::Deserialize;

use super::Status;

#[derive(Deserialize)]
pub struct GameCreatePayload {
    pub title: String,
    pub image_url: Option<String>,
    pub status: Option<Status>,
    pub rating: Option<u8>,
    pub categories: Option<Vec<String>>,
    pub note: Option<String>,
}

#[derive(Deserialize)]
pub struct GameUpdatePayload {
    pub title: String,
    pub image_url: Option<String>,
    pub status: Option<Status>,
    pub rating: Option<u8>,
    pub categories: Option<Vec<String>>,
    pub note: Option<String>,
}
