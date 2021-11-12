use std::{
    collections::HashMap,
    net::SocketAddr,
    sync::{Arc, RwLock},
    time::Duration,
};

use axum::{
    error_handling::HandleErrorLayer, http::StatusCode, AddExtensionLayer, BoxError, Router,
};
use tower::ServiceBuilder;
use tower_http::trace::TraceLayer;
use uuid::Uuid;

use crate::{endpoints::games::entities::Game, router::MountEndpointsExt};

pub type Database = Arc<RwLock<HashMap<Uuid, Game>>>;

pub struct Server;

impl Server {
    pub async fn run() -> Result<(), Box<dyn std::error::Error>> {
        let database = Database::default();

        let middleware = ServiceBuilder::new()
            .layer(HandleErrorLayer::new(|error: BoxError| {
                if error.is::<tower::timeout::error::Elapsed>() {
                    Ok(StatusCode::REQUEST_TIMEOUT)
                } else {
                    Err((
                        StatusCode::INTERNAL_SERVER_ERROR,
                        format!("Unhandled internal error: {}", error),
                    ))
                }
            }))
            .timeout(Duration::from_secs(10))
            .layer(TraceLayer::new_for_http())
            .layer(AddExtensionLayer::new(database))
            .into_inner();

        let router = Router::new().mount_endpoints().layer(middleware);

        let address = SocketAddr::from(([127, 0, 0, 1], 3000));

        tracing::debug!("Listening on: {}", address);

        axum::Server::bind(&address)
            .serve(router.into_make_service())
            .await?;

        Ok(())
    }
}
