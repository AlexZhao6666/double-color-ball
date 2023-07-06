use tracing_log::{log, LogTracer};
use tracing_subscriber::EnvFilter;
use tracing_subscriber::layer::SubscriberExt;
use crate::CLI;

pub fn init_log() {
    let tracing_level = tracing::Level::INFO;
    let _ = LogTracer::init_with_filter(log::LevelFilter::Info);
    let filter = EnvFilter::from_default_env()
        .add_directive(tracing_level.into())
        .add_directive("hyper=info".parse().unwrap())
        .add_directive("warp=info".parse().unwrap())
        .add_directive("warp=warn".parse().unwrap())
        .add_directive("tokio_util=info".parse().unwrap())
        .add_directive("api".parse().unwrap());

    let subscriber = tracing_subscriber::fmt::Subscriber::builder()
        .with_env_filter(filter)
        .with_target(false)
        .finish();

    tracing::subscriber::set_global_default(subscriber).expect("unable to set global default subscriber");

}