use axum::{body::HttpBody, response::IntoResponse};
use hyper::{header::CONTENT_TYPE, Body, Response, StatusCode};
use serde_json::json;
use thiserror::Error;

use crate::authentication::error::AuthenticationError;

pub trait MapToStatusCode {
    fn map_to_status_code(&self) -> StatusCode;
}

impl MapToStatusCode for sqlx::Error {
    fn map_to_status_code(&self) -> StatusCode {
        match self {
            sqlx::Error::RowNotFound => StatusCode::NOT_FOUND,
            _ => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

#[derive(Error, Debug)]
pub enum ProcessorError {
    #[error("authentication error")]
    AuthenticationError(#[from] crate::authentication::error::AuthenticationError),
    #[error("database error")]
    DatabaseError(#[from] sqlx::Error),
}

impl From<argon2::Error> for ProcessorError {
    fn from(_: argon2::Error) -> Self {
        Self::AuthenticationError(AuthenticationError::TokenCreation)
    }
}

impl From<jwt_simple::Error> for ProcessorError {
    fn from(_: jwt_simple::Error) -> Self {
        Self::AuthenticationError(AuthenticationError::TokenCreation)
    }
}

impl IntoResponse for ProcessorError {
    type Body = Body;

    type BodyError = <Self::Body as HttpBody>::Error;

    fn into_response(self) -> Response<Self::Body> {
        tracing::error!("{}", self);

        let (status, message) = {
            match self {
                ProcessorError::AuthenticationError(error) => {
                    tracing::error!("{}", error);

                    (error.map_to_status_code(), format!("{}", error))
                }
                ProcessorError::DatabaseError(error) => {
                    tracing::error!("{}", error);

                    (error.map_to_status_code(), format!("{}", error))
                }
            }
        };

        let response = Response::builder()
            .status(status)
            .header(CONTENT_TYPE, "application/json")
            .body(Body::from(json!({ "message": message }).to_string()))
            .unwrap();

        response
    }
}
