use serde::Serialize;
use serde::Deserialize;

pub struct PrizePool {
    money:u64,
    current_round:u32,
    // 1一开始 2已停止投注 3 以开奖
    current_round_status:u8,
    // 本轮参与人数
    current_round_num:u32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TicketPurchaseInfo {
    pub user: String,
    pub round_number: u32,
    pub count:u32,
    pub gates: u64,
    pub red_ball_1: u32,
    pub red_ball_2: u32,
    pub red_ball_3: u32,
    pub red_ball_4: u32,
    pub red_ball_5: u32,
    pub red_ball_6: u32,
    pub blue_ball_1: u32
}