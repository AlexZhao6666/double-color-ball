use std::net::{IpAddr, SocketAddr};
use std::str::FromStr;
use anyhow::Result;
use axum::Router;
use axum::routing::get;
use axum::routing::post;
use http::header::CONTENT_TYPE;
use http::{Method, StatusCode};
use tower_http::cors::{Any, CorsLayer};
use crate::vo::*;
use crate::vo::PrizePool;
use aleo_rpc_sdk::{AbstractClient, ProgramClient};
use axum::extract::{DefaultBodyLimit, State};
use axum::response::{IntoResponse, Response};
use axum_extra::response::ErasedJson;
use snarkvm::prelude::Value;
use snarkvm_console_network::Testnet3;
use tower_http::trace::TraceLayer;

#[derive(Clone)]
pub struct Rest {
    rest_socket:SocketAddr,
    node_url:String,
}

impl Rest {
    pub fn start(rest_socket: SocketAddr) -> Result<Self> {
        let mut server = Rest{
            rest_socket,
            node_url:"http://localhost:3030/testnet3/".to_string()
        };
        server.spawn_server(rest_socket);
        Ok(server)
    }

    pub fn spawn_server(&mut self,rest_ip:SocketAddr) {
        let cors = CorsLayer::new()
            .allow_origin(Any)
            .allow_methods([Method::GET, Method::POST, Method::OPTIONS])
            .allow_headers([CONTENT_TYPE]);

        let router:Router = {
            Router::new()
                .route("/prizepool",get(Self::get_price_pool))
                .with_state(self.clone())
                .layer(TraceLayer::new_for_http())
                .layer(cors)
                .layer(DefaultBodyLimit::max(10 * 1024 * 1024))
        };
        tokio::spawn(async move {
            axum::Server::bind(&rest_ip)
                .serve(router.into_make_service_with_connect_info::<SocketAddr>())
                .await
                .expect("couldn't start rest server");
        });
    }
}

impl Rest {
    pub (crate) async fn get_price_pool(State(rest): State<Self>) -> Result<ErasedJson, RestError> {
        let program_client = ProgramClient::new("http://localhost:3030/testnet3".to_string());
        let result = program_client.query_mapping_value("double_color_ball.aleo".to_string(),"currentPrizePoolMap".to_string(),"1u8".to_string()).await;
        return Ok(ErasedJson::pretty(result));
    }
}


pub struct RestError(pub String);

impl IntoResponse for RestError {
    fn into_response(self) -> Response {
        (StatusCode::INTERNAL_SERVER_ERROR, format!("Something went wrong: {}", self.0)).into_response()
    }
}

impl From<anyhow::Error> for RestError {
    fn from(err: anyhow::Error) -> Self {
        Self(err.to_string())
    }
}