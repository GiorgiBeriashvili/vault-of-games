use axum::{
    body::{boxed, Body, BoxBody},
    http::Response,
};
use futures::future::BoxFuture;
use hyper::{
    header::{AUTHORIZATION, CONTENT_TYPE},
    Request, StatusCode,
};
use jwt_simple::{
    prelude::{EdDSAPublicKeyLike, JWTClaims, NoCustomClaims},
    reexports::coarsetime::Duration,
};
use serde_json::json;
use std::time::{SystemTime, UNIX_EPOCH};
use tower_http::auth::AsyncAuthorizeRequest;

use super::keys::LAZY_KEYPAIR;

#[derive(Clone, Copy)]
pub struct JWTAuthorizationLayer;

impl AsyncAuthorizeRequest for JWTAuthorizationLayer {
    type Output = JWTClaims<NoCustomClaims>;
    type Future = BoxFuture<'static, Option<JWTClaims<NoCustomClaims>>>;
    type ResponseBody = BoxBody;

    fn authorize<B>(&mut self, request: &Request<B>) -> Self::Future {
        let claims = request
            .headers()
            .get(AUTHORIZATION)
            .and_then(|header_value| header_value.to_str().ok())
            .and_then(|bearer| bearer.strip_prefix("Bearer "))
            .map(|token| {
                LAZY_KEYPAIR
                    .public_key
                    .verify_token::<NoCustomClaims>(token, None)
                    .ok()
            })
            .unwrap_or(None)
            .filter(|claims| {
                let expiration = claims.expires_at.unwrap();
                let now = Duration::from_secs(
                    SystemTime::now()
                        .duration_since(UNIX_EPOCH)
                        .unwrap()
                        .as_secs(),
                );

                expiration > now
            });

        Box::pin(async move { claims })
    }

    fn on_authorized<B>(&mut self, request: &mut Request<B>, claims: JWTClaims<NoCustomClaims>) {
        request.extensions_mut().insert(claims);
    }

    fn unauthorized_response<B>(&mut self, _request: &Request<B>) -> Response<BoxBody> {
        Response::builder()
            .status(StatusCode::UNAUTHORIZED)
            .header(CONTENT_TYPE, "application/json")
            .body(boxed(Body::from(
                json!({ "message": "Please provide a valid Bearer token in Authorization header." }).to_string(),
            )))
            .unwrap()
    }
}
