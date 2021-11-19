use axum::Router;

use crate::endpoints::{games::GamesEndpoint, users::UsersEndpoint, Endpoint};

pub trait MountEndpointsExt {
    fn mount_endpoints(self) -> Self;
}

impl MountEndpointsExt for Router {
    fn mount_endpoints(self) -> Self {
        let games = GamesEndpoint::connect_router();
        let users = UsersEndpoint::connect_router();

        let endpoints = Router::new().merge(games).merge(users);

        let v1 = Router::new().nest("/v1", endpoints);

        self.merge(v1)
    }
}
