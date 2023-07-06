use std::fmt::format;
use std::process::Command;
use tracing::info;
use crate::rest::Rest;
use crate::vo::TicketPurchaseInfo;

pub struct BinaryClient {
    path:String,
}

impl BinaryClient {
    pub fn new(path:String) -> Self{
        BinaryClient {
            path
        }
    }

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
        println!("执行中....");
        let execute_result = Command::new(self.path.clone()).args(&args).output();
        if let Ok(output) = execute_result {
            if output.status.success() {
                let stdout = String::from_utf8_lossy(&output.stdout);
                let stderr = String::from_utf8_lossy(&output.stderr);

                if stderr.is_empty() {
                    if stdout.contains("Failed to") {
                        println!("执行失败: {}", stdout);
                    } else {
                        let new_tx_id = stdout.lines().rev().nth(1).unwrap();
                        println!("执行成功: {}", stdout);
                        println!("最新的交易id为: {}", new_tx_id);
                        let mut latest_transaction_id = rest.latest_transaction_id.write().await;
                        *latest_transaction_id = new_tx_id.to_string();
                        drop(latest_transaction_id);
                    }

                } else {
                    println!("执行出错: {}", stderr);
                }

            } else {
                let error_code = output.status.code().unwrap();
                println!("Command failed with exit code: {}", error_code);
                println!("error message: {:?}", output);
            }
        } else {
            println!("执行失败");
        }
    }
}