use std::env;
use std::net::SocketAddr;
use std::str::FromStr;
use clap::Parser;
use snarkvm::prelude::PrivateKey;
use snarkvm_console_network::Testnet3;
use crate::rest::Rest;
use tokio::main;
use tracing::info;
use crate::cli::CLI;
use crate::log::init_log;

mod rest;
mod vo;
mod binary;
mod cli;
mod log;

#[tokio::main]
async fn main() {

    dotenv::dotenv().ok();
    let mut cli = CLI::parse();
    init_log();

    let privateKey = PrivateKey::<Testnet3>::from_str(cli.privateKey.as_str()).unwrap();
    // 启动server
    Rest::start(cli.api,cli.nodeUrl,cli.txId,cli.snarkosPath,privateKey).unwrap();

    info!("double color ball api server started:{}",cli.api);
    std::future::pending::<()>().await;
}
