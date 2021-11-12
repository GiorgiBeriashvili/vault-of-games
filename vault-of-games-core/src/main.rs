mod endpoints;
mod router;
mod server;

use server::Server;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    if std::env::var_os("RUST_LOG").is_none() {
        std::env::set_var("RUST_LOG", "vault_of_games_core=debug,tower_http=debug")
    }

    tracing_subscriber::fmt::init();

    Server::run().await?;

    Ok(())
}
