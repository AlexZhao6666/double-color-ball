use std::net::SocketAddr;
use std::str::FromStr;
use crate::rest::Rest;
use tokio::main;

mod rest;
mod vo;
mod binary;

#[tokio::main]
async fn main() {
    Rest::start(SocketAddr::from_str("127.0.0.1:5111").unwrap());

    println!("double color ball api server started");
    std::future::pending::<()>().await;
}
