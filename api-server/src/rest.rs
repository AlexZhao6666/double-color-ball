use std::net::{IpAddr, SocketAddr};
use std::str::FromStr;
use std::string::ToString;
use std::sync::{Arc};
use anyhow::{bail, Result};
use axum::Router;
use axum::routing::get;
use axum::routing::post;
use http::header::CONTENT_TYPE;
use http::{Method, StatusCode};
use tower_http::cors::{Any, CorsLayer};
use crate::vo::*;
use crate::vo::PrizePool;
use crate::binary::*;
use aleo_rpc_sdk::{AbstractClient, ProgramClient, TransactionClient};
use axum::extract::{DefaultBodyLimit, Path, State};
use axum::response::{IntoResponse, Response};
use axum_extra::response::ErasedJson;
use snarkvm::prelude::{Ciphertext, PrivateKey, Record, Transaction, Value, ViewKey};
use snarkvm_console_network::Testnet3;
use tower_http::trace::TraceLayer;
use axum::Json;
use tokio::sync::RwLock;
use tracing::info;

const PROGRAM_ID: &str ="double_color_ball.aleo";

#[derive(Clone)]
pub struct Rest {
    pub rest_socket:SocketAddr,
    pub node_url:String,
    pub node_api:String,
    pub latest_transaction_id:Arc<RwLock<String>>,
    pub private_key:PrivateKey<Testnet3>,
    pub binary_client:BinaryClient,
}

impl Rest {
    pub fn start(rest_socket: SocketAddr,baseUrl:String,txId:String,snarkos_path:String,private_key:PrivateKey<Testnet3>) -> Result<Self> {
        let mut server = Rest{
            rest_socket,
            node_url:baseUrl.clone(),
            node_api:baseUrl+"/testnet3",
            latest_transaction_id: Arc::new(RwLock::new(txId.to_string())),
            private_key,
            binary_client:BinaryClient{
                path: snarkos_path,
            }
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
                .route("/round/start/:round",get(Self::execute_new_round_lottery_drawing))
                .route("/round/ticketpurchase",post(Self::execute_ticket_purchase))
                .route("/round/stop/:round",get(Self::execute_stop_lottery_drawing))
                .route("/round/drawprice/:round",get(Self::execute_draw_price))
                .route("/prizepool",get(Self::get_price_pool))
                .route("/lotterydraw/:round",get(Self::get_lottery_Drawing))
                .route("/winninglist/:round",get(Self::get_winning_list))

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

    // 开启新一期
    pub (crate) async fn execute_new_round_lottery_drawing(State(rest): State<Self>,Path(round): Path<u32>) -> Result<ErasedJson, RestError> {
        // 获取最新的transaction
        let record_str = rest.queryLatestRecord().await;
        rest.clone().binary_client.execute_new_round_lottery_drawing(round,record_str,rest).await;
        Ok(ErasedJson::pretty("{}"))
    }

    // 投注
    pub (crate) async fn execute_ticket_purchase(State(rest): State<Self>,Json(ticketPurchase): Json<TicketPurchaseInfo>) -> Result<ErasedJson, RestError> {
        // 获取最新的transaction
        let record_str = rest.queryLatestRecord().await;
        rest.clone().binary_client.execute_ticket_purchase(ticketPurchase,record_str,rest).await;
        Ok(ErasedJson::pretty("{}"))
    }

    // 停止投注
    pub (crate) async fn execute_stop_lottery_drawing(State(rest): State<Self>,Path(round): Path<u32>) -> Result<ErasedJson, RestError> {
        // 获取最新的transaction
        let record_str = rest.queryLatestRecord().await;
        rest.clone().binary_client.execute_stop_lottery_drawing(round,record_str,rest).await;
        Ok(ErasedJson::pretty("{}"))
    }

    // 开奖
    pub (crate) async fn execute_draw_price(State(rest): State<Self>,Path(round): Path<u32>) -> Result<ErasedJson, RestError> {
        // 获取最新的transaction
        let record_str = rest.queryLatestRecord().await;
        rest.clone().binary_client.execute_draw_price(round,record_str,rest).await;
        Ok(ErasedJson::pretty("{}"))
    }

    // 获取奖池信息
    pub (crate) async fn get_price_pool(State(rest): State<Self>) -> Result<ErasedJson, RestError> {
        let program_client = ProgramClient::new(rest.node_api);
        let result = program_client.query_mapping_value(PROGRAM_ID.to_string(),"currentPrizePoolMap".to_string(),"1u8".to_string()).await;
        return Ok(ErasedJson::pretty(result));
    }

    // 获取摇号信息
    pub (crate) async fn get_lottery_Drawing(State(rest): State<Self>,Path(round): Path<u32>) -> Result<ErasedJson, RestError> {
        let program_client = ProgramClient::new(rest.node_api);
        let result = program_client.query_mapping_value(PROGRAM_ID.to_string(),"lotteryDrawingMap".to_string(),round.to_string()+"u32").await;
        return Ok(ErasedJson::pretty(result));
    }

    // 获取中奖名单
    pub (crate) async fn get_winning_list(State(rest): State<Self>,Path(round): Path<u32>) -> Result<ErasedJson, RestError> {
        let program_client = ProgramClient::new(rest.node_api);
        let result = program_client.query_mapping_value(PROGRAM_ID.to_string(),"winningListMap".to_string(),round.to_string()+"u32").await;
        return if let Some(data) = result {
            Ok(ErasedJson::pretty(data))
        } else {
            Ok(ErasedJson::pretty("{}"))
        }

    }

    // 查询最新交易对应的解密后的record
    pub async fn queryLatestRecord(&self) -> String{
        let transaction_client = TransactionClient::new(self.node_api.clone());
        let latest_id = self.latest_transaction_id.read().await;
        info!("最新交易id为:{}",latest_id.clone());
        let transactions = transaction_client.query_transaction_by_id(latest_id.clone()).await;
        let fee = transactions.fee_transition();
        if let Some(info) = fee {
            let first_output = info.transition().outputs().get(0);
            if let Some(finalInfo) = first_output{
                let ciphertext = finalInfo.record().unwrap().1.to_string();
                let ciphertext_record = Record::<Testnet3, Ciphertext<Testnet3>>::from_str(ciphertext.as_str()).unwrap();
                let view_key = ViewKey::try_from(self.private_key).unwrap();
                match ciphertext_record.decrypt(&view_key) {
                    Ok(plaintext_record) => return plaintext_record.to_string(),
                    Err(e) => panic!("record解密失败"),
                };
            } else {
                panic!("查询record出错")
            }
        } else {
            panic!("查询record出错")
        }

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