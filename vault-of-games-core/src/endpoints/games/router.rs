use axum::{routing::get, Router};
use tower_http::auth::AsyncRequireAuthorizationLayer;

use crate::{authentication::middleware::JWTAuthorizationLayer, endpoints::Endpoint};

use super::{processor::GamesProcessor, GamesEndpoint};

impl Endpoint for GamesEndpoint {
    fn connect_router() -> Router {
        let routes = Router::new()
            .route(
                "/",
                get(GamesProcessor::read_all).post(GamesProcessor::create),
            )
            .route(
                "/:id",
                get(GamesProcessor::read)
                    .patch(GamesProcessor::update)
                    .delete(GamesProcessor::delete),
            );

        Router::new()
            .nest("/games", routes)
            .layer(AsyncRequireAuthorizationLayer::new(JWTAuthorizationLayer))
    }
}
