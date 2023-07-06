use std::fmt::format;
use std::process::Command;
use tracing::{error, info};
use crate::rest::Rest;
use crate::vo::TicketPurchaseInfo;

#[derive(Clone)]
pub struct BinaryClient {
    pub path:String,
}

impl BinaryClient {
    pub fn new(path:String) -> Self{
        BinaryClient {
            path
        }
    }

    // 执行投注
    pub async fn execute_ticket_purchase(&self,ticketPurchase:TicketPurchaseInfo,record:String,rest:Rest) {
        info!("用户投注信息是:{:?}",ticketPurchase);
        let mut user_info_str = format!("user:{},round_number:{}u32,count:{}u32,gates:{}u64,red_ball_1:{}u32,red_ball_2:{}u32,red_ball_3:{}u32,red_ball_4:{}u32,red_ball_5:{}u32,red_ball_6:{}u32,blue_ball_1:{}u32",
                                    ticketPurchase.user,ticketPurchase.round_number,ticketPurchase.count,ticketPurchase.gates,
                                    ticketPurchase.red_ball_1,ticketPurchase.red_ball_2,ticketPurchase.red_ball_3,ticketPurchase.red_ball_4,ticketPurchase.red_ball_5,ticketPurchase.red_ball_6,ticketPurchase.blue_ball_1);
        user_info_str = "{".to_string()+user_info_str.as_str()+"}";
        let broad_url = rest.node_api.clone()+"/transaction/broadcast";
        let private_key_str = rest.private_key.clone().to_string();
        let args = vec![
            "developer",
            "execute",
            "double_color_ball.aleo",
            "ticket_purchase",
            user_info_str.as_str(),
            "--query",
            rest.node_url.as_str(),
            "--broadcast",
            broad_url.as_str(),
            "--private-key",
            private_key_str.as_str(),
            "--fee",
            "91169000",
            "--record",
            record.as_str(),
        ];
        info!("投注执行中....");
        let execute_result = Command::new(self.path.clone()).args(&args).output();
        match execute_result {
            Ok(output) => {
                if output.status.success() {
                    let stdout = String::from_utf8_lossy(&output.stdout);
                    let stderr = String::from_utf8_lossy(&output.stderr);

                    if stderr.is_empty() {
                        if stdout.contains("Failed to") {
                            error!("投注:执行失败: {}", stdout);
                        } else {
                            let new_tx_id = stdout.lines().rev().nth(1).unwrap();
                            info!("投注:执行成功: {}", stdout);
                            info!("投注:最新的交易id为: {}", new_tx_id);
                            let mut latest_transaction_id = rest.latest_transaction_id.write().await;
                            *latest_transaction_id = new_tx_id.to_string();
                            drop(latest_transaction_id);
                        }

                    } else {
                        error!("投注:执行出错: {}", stderr);
                    }

                } else {
                    error!("投注:执行失败: {:?}", output);
                }
            }
            Err(e) => {error!("投注:执行失败:{}",e);}
        }
    }

    // 开启一轮抽奖
    pub async fn execute_new_round_lottery_drawing(&self,round:u32,record:String,rest:Rest) {
        info!("正在开启第{}期双色球",round);
        let broad_url = rest.node_api.clone()+"/transaction/broadcast";
        let private_key_str = rest.private_key.clone().to_string();
        let round_str = (round.to_string()+"u32");
        let args = vec![
            "developer",
            "execute",
            "double_color_ball.aleo",
            "new_round_lottery_drawing",
            round_str.as_str(),
            "--query",
            rest.node_url.as_str(),
            "--broadcast",
            broad_url.as_str(),
            "--private-key",
            private_key_str.as_str(),
            "--fee",
            "91169000",
            "--record",
            record.as_str(),
        ];
        info!("开启执行中....");
        let execute_result = Command::new(self.path.clone()).args(&args).output();
        match execute_result {
            Ok(output) => {
                if output.status.success() {
                    let stdout = String::from_utf8_lossy(&output.stdout);
                    let stderr = String::from_utf8_lossy(&output.stderr);

                    if stderr.is_empty() {
                        if stdout.contains("Failed to") {
                            error!("开启:执行失败: {}", stdout);
                        } else {
                            let new_tx_id = stdout.lines().rev().nth(1).unwrap();
                            info!("开启:执行成功: {}", stdout);
                            info!("开启:最新的交易id为: {}", new_tx_id);
                            let mut latest_transaction_id = rest.latest_transaction_id.write().await;
                            *latest_transaction_id = new_tx_id.to_string();
                            drop(latest_transaction_id);
                        }

                    } else {
                        error!("开启:执行出错: {}", stderr);
                    }

                } else {
                    error!("开启:执行失败: {:?}", output);
                }
            }
            Err(e) => {error!("开启:执行失败:{}",e);}
        }
    }

    // 停止投注
    pub async fn execute_stop_lottery_drawing(&self,round:u32,record:String,rest:Rest) {
        info!("正在停止第{}期双色球投注",round);
        let broad_url = rest.node_api.clone()+"/transaction/broadcast";
        let private_key_str = rest.private_key.clone().to_string();
        let round_str = (round.to_string()+"u32");
        let args = vec![
            "developer",
            "execute",
            "double_color_ball.aleo",
            "stop_lottery_drawing",
            round_str.as_str(),
            "--query",
            rest.node_url.as_str(),
            "--broadcast",
            broad_url.as_str(),
            "--private-key",
            private_key_str.as_str(),
            "--fee",
            "91169000",
            "--record",
            record.as_str(),
        ];
        info!("停止执行中....");
        let execute_result = Command::new(self.path.clone()).args(&args).output();
        match execute_result {
            Ok(output) => {
                if output.status.success() {
                    let stdout = String::from_utf8_lossy(&output.stdout);
                    let stderr = String::from_utf8_lossy(&output.stderr);

                    if stderr.is_empty() {
                        if stdout.contains("Failed to") {
                            error!("停止:执行失败: {}", stdout);
                        } else {
                            let new_tx_id = stdout.lines().rev().nth(1).unwrap();
                            info!("停止:执行成功: {}", stdout);
                            info!("停止:最新的交易id为: {}", new_tx_id);
                            let mut latest_transaction_id = rest.latest_transaction_id.write().await;
                            *latest_transaction_id = new_tx_id.to_string();
                            drop(latest_transaction_id);
                        }

                    } else {
                        error!("停止:执行出错: {}", stderr);
                    }

                } else {
                    error!("停止:执行失败: {:?}", output);
                }
            }
            Err(e) => {error!("停止:执行失败:{}",e);}
        }
    }

    // 开奖
    pub async fn execute_draw_price(&self,round:u32,record:String,rest:Rest) {
        info!("正在开启第{}期双色球",round);
        let broad_url = rest.node_api.clone()+"/transaction/broadcast";
        let private_key_str = rest.private_key.clone().to_string();
        let round_str = (round.to_string()+"u32");
        let args = vec![
            "developer",
            "execute",
            "double_color_ball.aleo",
            "draw_price",
            round_str.as_str(),
            "--query",
            rest.node_url.as_str(),
            "--broadcast",
            broad_url.as_str(),
            "--private-key",
            private_key_str.as_str(),
            "--fee",
            "91169000",
            "--record",
            record.as_str(),
        ];
        info!("开奖执行中....");
        let execute_result = Command::new(self.path.clone()).args(&args).output();
        match execute_result {
            Ok(output) => {
                if output.status.success() {
                    let stdout = String::from_utf8_lossy(&output.stdout);
                    let stderr = String::from_utf8_lossy(&output.stderr);

                    if stderr.is_empty() {
                        if stdout.contains("Failed to") {
                            error!("开奖:执行失败: {}", stdout);
                        } else {
                            let new_tx_id = stdout.lines().rev().nth(1).unwrap();
                            info!("开奖:执行成功: {}", stdout);
                            info!("开奖:最新的交易id为: {}", new_tx_id);
                            let mut latest_transaction_id = rest.latest_transaction_id.write().await;
                            *latest_transaction_id = new_tx_id.to_string();
                            drop(latest_transaction_id);
                        }

                    } else {
                        error!("开奖:执行出错: {}", stderr);
                    }

                } else {
                    error!("开奖:执行失败: {:?}", output);
                }
            }
            Err(e) => {error!("开奖:执行失败:{}",e);}
        }
    }
}