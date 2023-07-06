use std::net::SocketAddr;
use clap::Parser;

#[derive(Debug, Parser)]
#[clap(name = "api-server", about = "double color ball api server")]
pub struct CLI {

    #[clap(short, long)]
    pub txId:String,

    #[clap(short, long)]
    pub privateKey:String,

    #[clap(short, long)]
    pub api:SocketAddr,

    #[clap(short, long)]
    pub nodeUrl:String,

    #[clap(short, long)]
    pub snarkosPath:String,
}