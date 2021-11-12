use axum::Router;

use crate::endpoints::{games::GamesEndpoint, Endpoint};

pub trait MountEndpointsExt {
    fn mount_endpoints(self) -> Self;
}

impl MountEndpointsExt for Router {
    fn mount_endpoints(self) -> Self {
        let games = GamesEndpoint::connect_router();

        self.merge(games)
    }
}
