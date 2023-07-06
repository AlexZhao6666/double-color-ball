use std::process::Command;
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

    pub fn execute_ticket_purchase(&self,ticketPurchase:TicketPurchaseInfo) {
        let args = vec![
            "developer",
            "execute",
            "double_color_ball.aleo",
            "ticket_purchase",
            r#"{user:aleo1j8u3wrjucfmgrpe4ftarrkfxmqj7guefspz0q6tc04mena33gqzq28unrn,round_number:2u32,count:1u32,gates:100000000u64,red_ball_1:1u32,red_ball_2:2u32,red_ball_3:15u32,red_ball_4:16u32,red_ball_5:13u32,red_ball_6:30u32,blue_ball_1:8u32}"#,
            "--query",
            "http://localhost:3030",
            "--broadcast",
            "http://localhost:3030/testnet3/transaction/broadcast",
            "--private-key",
            "APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH",
            "--fee",
            "91169000",
            "--record",
            r#"{  owner: aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px.private,  microcredits: 93750000000000u64.private,  _nonce: 6920274239593709046067686672303803258301045128526467643854900331820009025231group.public}"#,
        ];
        let execute_result = Command::new(self.path.clone()).args(&args).output();
        if let Ok(output) = execute_result {
            if output.status.success() {
                let stdout = String::from_utf8_lossy(&output.stdout);
                let stderr = String::from_utf8_lossy(&output.stderr);
                println!("Command executed successfully!");
                println!("Stdout: {}", stdout);
                println!("Stderr: {}", stderr);
            } else {
                let error_code = output.status.code().unwrap();
                println!("Command failed with exit code: {}", error_code);
            }
        } else {
            println!("执行失败");
        }
    }
}