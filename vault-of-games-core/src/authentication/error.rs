use axum::{body::HttpBody, response::IntoResponse};
use hyper::{header::CONTENT_TYPE, Body, Response, StatusCode};
use serde::Serialize;
use serde_json::json;
use thiserror::Error;

#[derive(Error, Debug, Serialize)]
pub enum AuthenticationError {
    #[error("Wrong credentials")]
    WrongCredentials,
    #[error("Missing credentials")]
    MissingCredentials,
    #[error("Access token creation failed")]
    TokenCreation,
}

impl From<jwt_simple::Error> for AuthenticationError {
    fn from(_: jwt_simple::Error) -> Self {
        Self::TokenCreation
    }
}

impl IntoResponse for AuthenticationError {
    type Body = Body;

    type BodyError = <Self::Body as HttpBody>::Error;

    fn into_response(self) -> Response<Self::Body> {
        let response = Response::builder()
            .status(match self {
                AuthenticationError::WrongCredentials => StatusCode::UNAUTHORIZED,
                AuthenticationError::MissingCredentials => StatusCode::BAD_REQUEST,
                AuthenticationError::TokenCreation => StatusCode::INTERNAL_SERVER_ERROR,
            })
            .header(CONTENT_TYPE, "application/json")
            .body(Body::from(
                json!({ "message": self.to_string() }).to_string(),
            ))
            .unwrap();

        response
    }
}
