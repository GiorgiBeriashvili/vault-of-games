use axum::Router;

pub mod games;

pub trait Endpoint {
    fn connect_router() -> Router;
}
