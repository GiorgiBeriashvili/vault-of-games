use anyhow::Result;
use dotenv::dotenv;

mod authentication;
mod database;
mod endpoints;
mod error;
mod router;
mod server;

#[tokio::main]
async fn main() -> Result<()> {
    dotenv()?;

    tracing_subscriber::fmt::init();

    server::run().await?;

    Ok(())
}
