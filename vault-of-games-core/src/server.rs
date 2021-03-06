use std::{net::SocketAddr, time::Duration};

use anyhow::Result;
use axum::{
    error_handling::HandleErrorLayer, http::StatusCode, AddExtensionLayer, BoxError, Router, Server,
};
use tower::ServiceBuilder;
use tower_http::trace::TraceLayer;

use crate::{database::DatabaseConnectionPool, router::MountEndpointsExt};

pub async fn run() -> Result<()> {
    let pool = DatabaseConnectionPool::connect(&std::env::var("DATABASE_URL")?).await?;

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
        .layer(AddExtensionLayer::new(pool))
        .into_inner();

    let router = Router::new().mount_endpoints().layer(middleware);

    let address = SocketAddr::from(([127, 0, 0, 1], 3000));

    tracing::debug!("Listening on: {}", address);

    Server::bind(&address)
        .serve(router.into_make_service())
        .await?;

    Ok(())
}
