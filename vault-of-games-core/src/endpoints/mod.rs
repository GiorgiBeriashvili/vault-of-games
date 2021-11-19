use axum::Router;

pub mod games;
pub mod users;

pub trait Endpoint {
    fn connect_router() -> Router;
}
