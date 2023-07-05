use std::net::SocketAddr;
use std::str::FromStr;
use crate::rest::Rest;
use tokio::main;

mod rest;
mod vo;

#[tokio::main]
async fn main() {
    println!("Hello, world!");

    Rest::start(SocketAddr::from_str("127.0.0.1:5111").unwrap());

    std::future::pending::<()>().await;
}
