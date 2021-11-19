use std::error::Error;

use axum::http::StatusCode;

pub trait Processor {
    fn error<E: Error>(error: E) -> StatusCode {
        tracing::error!("{}", error);

        StatusCode::INTERNAL_SERVER_ERROR
    }
}
