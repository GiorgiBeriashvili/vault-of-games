pub mod error;
pub mod keys;
pub mod middleware;

use serde::Serialize;

#[derive(Debug, Serialize)]
pub struct AuthenticationResponse {
    access_token: String,
    token_type: String,
}

impl AuthenticationResponse {
    pub fn new(access_token: String) -> Self {
        Self {
            access_token,
            token_type: "Bearer".to_string(),
        }
    }
}
