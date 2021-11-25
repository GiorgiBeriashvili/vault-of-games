use axum::{body::HttpBody, response::IntoResponse};
use hyper::{header::CONTENT_TYPE, Body, Response, StatusCode};
use serde::Serialize;
use serde_json::json;
use thiserror::Error;

use crate::error::MapToStatusCode;

#[derive(Error, Debug, Serialize)]
pub enum AuthenticationError {
    #[error("wrong credentials")]
    WrongCredentials,
    #[error("missing credentials")]
    MissingCredentials,
    #[error("access token creation failed")]
    TokenCreation,
}

impl MapToStatusCode for AuthenticationError {
    fn map_to_status_code(&self) -> StatusCode {
        match self {
            AuthenticationError::WrongCredentials => StatusCode::UNAUTHORIZED,
            AuthenticationError::MissingCredentials => StatusCode::BAD_REQUEST,
            AuthenticationError::TokenCreation => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

impl IntoResponse for AuthenticationError {
    type Body = Body;

    type BodyError = <Self::Body as HttpBody>::Error;

    fn into_response(self) -> Response<Self::Body> {
        let response = Response::builder()
            .status(self.map_to_status_code())
            .header(CONTENT_TYPE, "application/json")
            .body(Body::from(
                json!({ "message": self.to_string() }).to_string(),
            ))
            .unwrap();

        response
    }
}
