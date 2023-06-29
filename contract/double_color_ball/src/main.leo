// The 'double_color_ball' program.
program double_color_ball.aleo {

    // 奖池
    struct PrizePool {
        money:u64,
        current_round:u32,
        // 1一开始 2已结束
        current_round_status:u8,
        // 本轮参与人数
        current_round_num:u32,
    }

    // 开奖
    struct LotteryDrawing {
        round_number: u32,  
        red_ball_1: u32,
        red_ball_2: u32,
        red_ball_3: u32,
        red_ball_4: u32,
        red_ball_5: u32,
        red_ball_6: u32,
        blue_ball_1: u32 
    }

    // 购买彩票
    record TicketPurchaseRecord {
        round_number: u32,  
        owner: address,
        gates: u64,
        count: u32,
        red_ball_1: u32,
        red_ball_2: u32,
        red_ball_3: u32,
        red_ball_4: u32,
        red_ball_5: u32,
        red_ball_6: u32,
        blue_ball_1: u32 
    }

    struct TicketPurchaseInfo {
        user: address,
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

    struct TicketPurchasePriceInfo {
        user: address,
        round_number: u32, 
        count:u32, 
        gates: u64,
        red_ball_1: u32,
        red_ball_2: u32,
        red_ball_3: u32,
        red_ball_4: u32,
        red_ball_5: u32,
        red_ball_6: u32,
        blue_ball_1: u32,
        reward:u64,

    }

    struct DrawPriceInfo {
        seed_min:u32,
        seed_max:u32,
    }

    // 当前奖池信息
    mapping currentPrizePoolMap: u8=>PrizePool;
    // 轮次对应的抽奖信息
    mapping lotteryDrawingMap: u32 => LotteryDrawing;
    // 轮次对应的参与者
    mapping ticketPurchaseMap: u32 => TicketPurchaseInfo;
    // 中奖名单
    mapping firstWinningListMap: u32 => TicketPurchasePriceInfo;
    mapping secondWinningListMap: u32 => TicketPurchasePriceInfo;
    mapping thirdWinningListMap: u32 => TicketPurchasePriceInfo;

    mapping firstWinningListAmount:u32 => u64;
    mapping secondWinningListAmount:u32 => u64;
    mapping thirdWinningListAmount:u32 => u64;

    // 存放六个红色球
    mapping priceDrawingTempMap: u32 =>u8;


    transition new_round_lottery_drawing () {
        return then finalize(self.caller);
    }
    finalize new_round_lottery_drawing (caller:address) {

        // 默认奖池
        let default_prize_pool:PrizePool = PrizePool {
            money:0u64,
            current_round:0u32,
            current_round_status:0u8,
            current_round_num:0u32,
        };
        // 获取当前奖池
        let current_prize_pool:PrizePool = Mapping::get_or_use(currentPrizePoolMap,1u8,default_prize_pool);

        let new_prize_pool:PrizePool = PrizePool {
            money:current_prize_pool.money,
            current_round:current_prize_pool.current_round+1u32,
            current_round_status:1u8,
            current_round_num:0u32,
        };
        // 存储奖池信息
        Mapping::set(currentPrizePoolMap,1u8,new_prize_pool);
    }

    // 购买彩票
    transition ticket_purchase(ticketPurchaseRecord:TicketPurchaseRecord) -> TicketPurchaseRecord {
        let info:TicketPurchaseInfo = TicketPurchaseInfo {
            user: ticketPurchaseRecord.owner,
            round_number: ticketPurchaseRecord.round_number, 
            count:ticketPurchaseRecord.count, 
            gates: ticketPurchaseRecord.gates,
            red_ball_1: ticketPurchaseRecord.red_ball_1,
            red_ball_2: ticketPurchaseRecord.red_ball_2,
            red_ball_3: ticketPurchaseRecord.red_ball_3,
            red_ball_4: ticketPurchaseRecord.red_ball_4,
            red_ball_5: ticketPurchaseRecord.red_ball_5,
            red_ball_6: ticketPurchaseRecord.red_ball_6,
            blue_ball_1: ticketPurchaseRecord.blue_ball_1, 
        };
        return then finalize(info);
    }

    finalize ticket_purchase(ticketPurchaseInfo:TicketPurchaseInfo) {
        // 确认当前轮次允许购买
        let default_prize_pool:PrizePool = PrizePool {
            money:0u64,
            current_round:0u32,
            current_round_status:0u8,
            current_round_num:0u32,
        };
        // 获取当前奖池
        let current_prize_pool:PrizePool = Mapping::get_or_use(currentPrizePoolMap,1u8,default_prize_pool);

        // 轮次正确，并且当前轮次还是开启状态可以投注
        if(!(current_prize_pool.current_round == ticketPurchaseInfo.round_number && current_prize_pool.current_round_status == 1u8)) {
            // 验证失败
            assert_eq(0u8, 1u8);
        } 

        // 更新奖池金额金额和投奖人数
        let new_prize_pool:PrizePool = PrizePool {
            money:current_prize_pool.money+ticketPurchaseInfo.gates,
            current_round:current_prize_pool.current_round,
            current_round_status:current_prize_pool.current_round_status,
            current_round_num:current_prize_pool.current_round_num+1u32,
        };
      
        Mapping::set(currentPrizePoolMap,1u8,new_prize_pool);

        // TODO 有数组类型后修改
        let current_ticket_purchase:TicketPurchaseInfo = TicketPurchaseInfo {
            user: ticketPurchaseInfo.user,
            round_number: current_prize_pool.current_round, 
            count:ticketPurchaseInfo.count, 
            gates: ticketPurchaseInfo.gates,
            red_ball_1: ticketPurchaseInfo.red_ball_1,
            red_ball_2: ticketPurchaseInfo.red_ball_2,
            red_ball_3: ticketPurchaseInfo.red_ball_3,
            red_ball_4: ticketPurchaseInfo.red_ball_4,
            red_ball_5: ticketPurchaseInfo.red_ball_5,
            red_ball_6: ticketPurchaseInfo.red_ball_6,
            blue_ball_1: ticketPurchaseInfo.blue_ball_1 
        };
        // 开始投注
        // 获取本轮用户map
        Mapping::set(ticketPurchaseMap,new_prize_pool.current_round_num,current_ticket_purchase);
    }

    transition stop_lottery_drawing(round:u32){
        return then finalize(round);
    }

    // 停止投注 准备开奖
    finalize stop_lottery_drawing(round:u32){
        let current_prize_pool:PrizePool = Mapping::get(currentPrizePoolMap,1u8);
        if(current_prize_pool.current_round != round) {
            assert_eq(0u8, 1u8);
        }

        let new_prize_pool:PrizePool = PrizePool{
            money:current_prize_pool.money,
            current_round:current_prize_pool.current_round,
            current_round_status:2u8,
            current_round_num:current_prize_pool.current_round_num,
        };
        Mapping::set(currentPrizePoolMap,1u8,new_prize_pool);
    }

    // 开奖,按照投注顺序，开始检索
    // 一等奖分80% 【1蓝、3红】
    // 二等奖分18%  【1蓝、1红】【3红】
    // 三等奖分2%  【1蓝】【2红】
    // 共同分奖池70%的资金
    transition draw_price(drawPrice:DrawPriceInfo) {

        return then finalize(drawPrice,self.caller);
    }

    finalize draw_price(drawPrice:DrawPriceInfo,caller:address) {

        // 摇号
        let red_ball_1:u32 = 0u32;
        let red_ball_2:u32 = 0u32;
        let red_ball_3:u32 = 0u32;
        let red_ball_4:u32 = 0u32;
        let red_ball_5:u32 = 0u32;
        let red_ball_6:u32 = 0u32;
        let mod_number:u32 = 33u32;
        let seed_min:u32 = drawPrice.seed_min;
        let finish:bool = false;
        for i:u32 in 0u32..100u32 {
            if (!finish){
                let cur_number:u32= seed_min+i+3u32;
                let rand:u32 = cur_number.mod(33u32)+1u32;

                if (red_ball_1==0u32) {
                    red_ball_1 = rand;
                } else if (red_ball_2==0u32 &&(red_ball_1 != rand)) {
                    red_ball_2 = rand;
                } else if (red_ball_3==0u32 &&(red_ball_1 != rand && red_ball_2 != rand)) {
                    red_ball_3 = rand;
                } else if (red_ball_4==0u32 &&(red_ball_1 != rand && red_ball_2 != rand && red_ball_3 != rand)) {
                    red_ball_4 = rand;
                } else if (red_ball_5==0u32&&(red_ball_1 != rand && red_ball_2 != rand && red_ball_3 != rand && red_ball_4 != rand)) {
                    red_ball_5 = rand;
                } else if (red_ball_6==0u32&&(red_ball_1 != rand && red_ball_2 != rand && red_ball_3 != rand && red_ball_4 != rand && red_ball_5 != rand)) {
                    red_ball_6 = rand;
                    finish =true;
                } 
            }
        }

        if (!finish) {
            assert_eq(0u8, 1u8);
        }
        Mapping::set(priceDrawingTempMap,red_ball_1,1u8);
        Mapping::set(priceDrawingTempMap,red_ball_2,1u8);
        Mapping::set(priceDrawingTempMap,red_ball_3,1u8);
        Mapping::set(priceDrawingTempMap,red_ball_4,1u8);
        Mapping::set(priceDrawingTempMap,red_ball_5,1u8);
        Mapping::set(priceDrawingTempMap,red_ball_6,1u8);

        let height:u32 = block.height;
        let blue_number:u32= seed_min+height+3u32;
        let blue_ball_1:u32 = blue_number.mod(33u32)+1u32;
        
        let current_prize_pool:PrizePool = Mapping::get(currentPrizePoolMap,1u8);

        // 中奖
        let end:u32 = current_prize_pool.current_round_num+1u32;


        let first_count:u32 = 0u32;
        let second_count:u32 = 0u32;
        let third_count:u32 = 0u32;

        let finish_flag:bool = false; 
        for i:u32 in 1u32..100u32 {
            if (!finish_flag) {
                let index_final:u32 = i;
                let temp_ticket_purchase:TicketPurchaseInfo = Mapping::get(ticketPurchaseMap,index_final);
                let cur_prize:u8 = 0u8;
                if(temp_ticket_purchase.blue_ball_1 == blue_ball_1) {
                    // 中一个蓝球
                    let red_meet_count:u8 = 0u8;
                    let flag1:u8 = Mapping::get_or_use(priceDrawingTempMap,temp_ticket_purchase.red_ball_1,0u8);
                    if(flag1 == 1u8) {
                        // 中一个
                        red_meet_count = red_meet_count +1u8;
                    }
                    let flag2:u8 = Mapping::get_or_use(priceDrawingTempMap,temp_ticket_purchase.red_ball_2,0u8);
                    if(flag2 == 1u8) {
                        // 中一个
                        red_meet_count = red_meet_count +1u8;
                    }
                    let flag3:u8 = Mapping::get_or_use(priceDrawingTempMap,temp_ticket_purchase.red_ball_3,0u8);
                    if(flag3 == 1u8) {
                        // 中一个
                        red_meet_count = red_meet_count +1u8;
                    }
                    let flag4:u8 = Mapping::get_or_use(priceDrawingTempMap,temp_ticket_purchase.red_ball_4,0u8);
                    if(flag4 == 1u8) {
                        // 中一个
                        red_meet_count = red_meet_count +1u8;
                    }
                    let flag5:u8 = Mapping::get_or_use(priceDrawingTempMap,temp_ticket_purchase.red_ball_5,0u8);
                    if(flag5 == 1u8) {
                        // 中一个
                        red_meet_count = red_meet_count +1u8;
                    }
                    let flag6:u8 = Mapping::get_or_use(priceDrawingTempMap,temp_ticket_purchase.red_ball_6,0u8);
                    if(flag6 == 1u8) {
                        // 中一个
                        red_meet_count = red_meet_count +1u8;
                    }

                    if (red_meet_count>=3u8) {
                        cur_prize = 1u8;
                    } else if (red_meet_count >=1u8) {
                        cur_prize = 2u8;
                    } else {
                        cur_prize = 3u8;
                    }
                } else {
                    // 未中蓝球
                    let red_meet_count:u8 = 0u8;
                    let flag1:u8 = Mapping::get_or_use(priceDrawingTempMap,temp_ticket_purchase.red_ball_1,0u8);
                    if(flag1 == 1u8) {
                        // 中一个
                        red_meet_count = red_meet_count +1u8;
                    }
                    let flag2:u8 = Mapping::get_or_use(priceDrawingTempMap,temp_ticket_purchase.red_ball_2,0u8);
                    if(flag2 == 1u8) {
                        // 中一个
                        red_meet_count = red_meet_count +1u8;
                    }
                    let flag3:u8 = Mapping::get_or_use(priceDrawingTempMap,temp_ticket_purchase.red_ball_3,0u8);
                    if(flag3 == 1u8) {
                        // 中一个
                        red_meet_count = red_meet_count +1u8;
                    }
                    let flag4:u8 = Mapping::get_or_use(priceDrawingTempMap,temp_ticket_purchase.red_ball_4,0u8);
                    if(flag4 == 1u8) {
                        // 中一个
                        red_meet_count = red_meet_count +1u8;
                    }
                    let flag5:u8 = Mapping::get_or_use(priceDrawingTempMap,temp_ticket_purchase.red_ball_5,0u8);
                    if(flag5 == 1u8) {
                        // 中一个
                        red_meet_count = red_meet_count +1u8;
                    }
                    let flag6:u8 = Mapping::get_or_use(priceDrawingTempMap,temp_ticket_purchase.red_ball_6,0u8);
                    if(flag6 == 1u8) {
                        // 中一个
                        red_meet_count = red_meet_count +1u8;
                    }

                    if (red_meet_count>=3u8) {
                        cur_prize = 2u8;
                    } else if (red_meet_count >=2u8) {
                        cur_prize = 3u8;
                    }
                }
                
                // TODO 目前leo还不支持for里用set，等更新吧 写不动了
                // let price_info:TicketPurchasePriceInfo = TicketPurchasePriceInfo {
                //         user: temp_ticket_purchase.user,
                //         round_number: temp_ticket_purchase.round_number, 
                //         count:temp_ticket_purchase.count, 
                //         gates: temp_ticket_purchase.gates,
                //         red_ball_1: temp_ticket_purchase.red_ball_1,
                //         red_ball_2: temp_ticket_purchase.red_ball_2,
                //         red_ball_3: temp_ticket_purchase.red_ball_3,
                //         red_ball_4: temp_ticket_purchase.red_ball_4,
                //         red_ball_5: temp_ticket_purchase.red_ball_5,
                //         red_ball_6: temp_ticket_purchase.red_ball_6,
                //         blue_ball_1: temp_ticket_purchase.blue_ball_1,
                //         reward:0u64,
                // };

                // if (cur_prize == 1u8) {
                //     // 判断first
                //     first_count = first_count+1u32;
                //     Mapping::set(firstWinningListMap,first_count,price_info);
                // } 
                // if (cur_prize == 2u8) {
                //     second_count = second_count+1u32;
                //     Mapping::set(secondWinningListMap,second_count,price_info);
                // } 
                // if (cur_prize == 3u8) {
                //     third_count = third_count + 1u32;
                //     Mapping::set(thirdWinningListMap,third_count,price_info);
                // }
            }
        }

        let first_devied_amount:u64 = 0u64;
        let second_devied_amount:u64 = 0u64;
        let third_devied_amount:u64 = 0u64;

        if first_count > 0u32 {
            // 一等奖有中奖的
            first_devied_amount = current_prize_pool.money*(70u64/100u64)*(80u64/100u64);
            Mapping::set(firstWinningListAmount,current_prize_pool.current_round,first_devied_amount);
        }

        if first_count > 0u32 {
            // 二等奖有中奖的
            second_devied_amount = current_prize_pool.money*(70u64/100u64)*(15u64/100u64);
            Mapping::set(secondWinningListAmount,current_prize_pool.current_round,second_devied_amount);
        }

        if third_count > 0u32 {
            // 三等奖有中奖的
            third_devied_amount = current_prize_pool.money*(70u64/100u64)*(5u64/100u64);
            Mapping::set(thirdWinningListAmount,current_prize_pool.current_round,third_devied_amount);
        }

        // 更新轮次状态和资金池剩余金额
        let left_money:u64 = current_prize_pool.money - first_devied_amount-second_devied_amount-third_devied_amount;
        let update_prize_pool:PrizePool = PrizePool{
            money:left_money,
            current_round:current_prize_pool.current_round,
            current_round_status:3u8,
            current_round_num:current_prize_pool.current_round_num,
        };
        Mapping::set(currentPrizePoolMap,1u8,update_prize_pool);

    }

}
