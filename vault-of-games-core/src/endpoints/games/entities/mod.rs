use std::str::FromStr;

use serde::{Deserialize, Serialize};
use sqlx::{Database, Decode, FromRow, Type};

pub mod payloads;

#[derive(Clone, Copy, Debug, Deserialize, Serialize, Type)]
#[serde(rename_all = "snake_case")]
#[sqlx(rename_all = "lowercase")]
pub enum Status {
    Untried,
    Progressing,
    Ended,
    Completed,
}

#[derive(Clone, Debug, Serialize)]
pub struct Categories {
    pub content: Vec<String>,
}

impl From<Option<Vec<String>>> for Categories {
    fn from(categories: Option<Vec<String>>) -> Self {
        Categories::new(categories.unwrap_or(vec![]))
    }
}

impl Categories {
    pub fn new(content: Vec<String>) -> Self {
        Self { content }
    }
}

impl FromStr for Categories {
    type Err = serde_json::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(Categories::new(serde_json::from_str(s)?))
    }
}

impl<'r, DB: Database> Decode<'r, DB> for Categories
where
    &'r str: Decode<'r, DB>,
{
    fn decode(
        value: <DB as sqlx::database::HasValueRef<'r>>::ValueRef,
    ) -> Result<Self, sqlx::error::BoxDynError> {
        let value = <&str as Decode<DB>>::decode(value)?;

        Ok(value.parse()?)
    }
}

#[derive(Clone, Debug, FromRow, Serialize)]
pub struct Game {
    pub id: String,
    pub user_id: String,
    pub title: String,
    pub image_url: Option<String>,
    pub status: Option<Status>,
    pub rating: Option<u8>,
    pub categories: Option<Categories>,
    pub note: Option<String>,
    pub created_at: String,
    pub updated_at: Option<String>,
}

impl Game {
    pub fn new(
        id: String,
        user_id: String,
        title: String,
        image_url: Option<String>,
        status: Option<Status>,
        rating: Option<u8>,
        categories: Option<Categories>,
        note: Option<String>,
        created_at: String,
        updated_at: Option<String>,
    ) -> Self {
        Self {
            id,
            user_id,
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
}
