pub struct PrizePool {
    money:u64,
    current_round:u32,
    // 1一开始 2已停止投注 3 以开奖
    current_round_status:u8,
    // 本轮参与人数
    current_round_num:u32,
}