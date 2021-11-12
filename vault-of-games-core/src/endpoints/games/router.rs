use axum::{routing::get, Router};

use crate::endpoints::Endpoint;

use super::{processor::Processor, GamesEndpoint};

impl Endpoint for GamesEndpoint {
    fn connect_router() -> Router {
        let routes = Router::new()
            .route("/", get(Processor::read_all).post(Processor::create))
            .route(
                "/:id",
                get(Processor::read)
                    .patch(Processor::update)
                    .delete(Processor::delete),
            );

        Router::new().nest("/games", routes)
    }
}
