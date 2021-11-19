use chrono::Utc;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use self::payloads::Update;

pub mod payloads;

#[derive(Clone, Copy, Deserialize, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum Status {
    Untried,
    Progressing,
    Ended,
    Completed,
}

#[derive(Clone, Serialize)]
pub struct Game {
    pub id: Uuid,
    pub title: String,
    pub image_url: Option<String>,
    pub status: Option<Status>,
    pub rating: Option<u8>,
    pub categories: Option<Vec<String>>,
    pub note: Option<String>,
    pub created_at: String,
    pub updated_at: Option<String>,
}

impl Game {
    pub fn new(
        id: Uuid,
        title: String,
        image_url: Option<String>,
        status: Option<Status>,
        rating: Option<u8>,
        categories: Option<Vec<String>>,
        note: Option<String>,
        created_at: String,
        updated_at: Option<String>,
    ) -> Self {
        Self {
            id,
            title,
            image_url,
            status,
            rating,
            categories,
            note,
            created_at,
            updated_at,
        }
    }

    pub fn update(&mut self, payload: Update) {
        self.title = payload.title;

        if let Some(image_url) = payload.image_url {
            self.image_url = image_url.into();
        }

        if let Some(status) = payload.status {
            self.status = status.into();
        }

        if let Some(rating) = payload.rating {
            self.rating = rating.into();
        }

        if let Some(categories) = payload.categories {
            self.categories = categories.into();
        }

        if let Some(note) = payload.note {
            self.note = note.into();
        }

        self.updated_at = Some(Utc::now().to_string());
    }
}
