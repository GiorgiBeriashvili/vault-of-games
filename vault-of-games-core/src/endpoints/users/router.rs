use axum::{
    routing::{get, post},
    Router,
};

use crate::endpoints::Endpoint;

use super::{processor::UsersProcessor, UsersEndpoint};

impl Endpoint for UsersEndpoint {
    fn connect_router() -> Router {
        let routes = Router::new()
            .route(
                "/:id",
                get(UsersProcessor::read)
                    .patch(UsersProcessor::update)
                    .delete(UsersProcessor::delete),
            )
            .route("/sign-in", post(UsersProcessor::sign_in))
            .route("/sign-up", post(UsersProcessor::sign_up));

        Router::new().nest("/users", routes)
    }
}
