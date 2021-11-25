use serde::Deserialize;

#[derive(Deserialize)]
pub struct UserAuthenticationPayload {
    pub username: String,
    pub password: String,
}

#[derive(Deserialize)]
pub struct UserUpdatePayload {
    pub username: String,
    pub password: String,
}
