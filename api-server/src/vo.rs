pub struct PrizePool {
    money:u64,
    current_round:u32,
    // 1一开始 2已停止投注 3 以开奖
    current_round_status:u8,
    // 本轮参与人数
    current_round_num:u32,
}

pub struct TicketPurchaseInfo {
    user: String,
    round_number: u32,
    count:u32,
    gates: u64,
    red_ball_1: u32,
    red_ball_2: u32,
    red_ball_3: u32,
    red_ball_4: u32,
    red_ball_5: u32,
    red_ball_6: u32,
    blue_ball_1: u32
}