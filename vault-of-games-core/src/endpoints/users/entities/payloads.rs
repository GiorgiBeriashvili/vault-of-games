use serde::Deserialize;

#[derive(Deserialize)]
pub struct Authenticate {
    pub username: String,
    pub password: String,
}

#[derive(Deserialize)]
pub struct Update {
    pub password: String,
}
