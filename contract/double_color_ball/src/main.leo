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
        index:u32,

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
    mapping winningListMap: u32 => TicketPurchasePriceInfo;



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


        let height:u32 = block.height;
        let blue_number:u32= seed_min+height+3u32;
        let blue_ball_1:u32 = blue_number.mod(33u32)+1u32;
        
        let current_prize_pool:PrizePool = Mapping::get(currentPrizePoolMap,1u8);

        // 中奖
        let end:u32 = current_prize_pool.current_round_num+1u32;

        let default_price_info:TicketPurchasePriceInfo = TicketPurchasePriceInfo {
                        user: caller,
                        round_number: 0u32, 
                        count:0u32, 
                        gates: 0u64,
                        red_ball_1: 0u32,
                        red_ball_2: 0u32,
                        red_ball_3: 0u32,
                        red_ball_4: 0u32,
                        red_ball_5: 0u32,
                        red_ball_6: 0u32,
                        blue_ball_1: 0u32,
                        reward:0u64,
                        index:10u32,
                };

        let first_price:TicketPurchasePriceInfo = default_price_info;
        let second_price:TicketPurchasePriceInfo = default_price_info;
        let third_price:TicketPurchasePriceInfo = default_price_info;
        let four_price:TicketPurchasePriceInfo = default_price_info;
        let five_price:TicketPurchasePriceInfo = default_price_info;

        let finish_flag_1:bool = false; 

        // 获取第一名
        for i:u32 in 1u32..100u32 {
            if (!finish_flag_1) {
                let index_final:u32 = i;
                let temp_ticket_purchase:TicketPurchaseInfo = Mapping::get(ticketPurchaseMap,index_final);
                let cur_prize:u8 = 0u8;
                let red_meet_count:u8 = 0u8;
                if(temp_ticket_purchase.blue_ball_1 == blue_ball_1) {
                    // 中一个蓝球
                    if(temp_ticket_purchase.red_ball_1==red_ball_1 || temp_ticket_purchase.red_ball_1==red_ball_2 ||  temp_ticket_purchase.red_ball_1==red_ball_3 ||  temp_ticket_purchase.red_ball_1==red_ball_4 ||  temp_ticket_purchase.red_ball_1==red_ball_5 ||  temp_ticket_purchase.red_ball_1==red_ball_6) {
                         red_meet_count = red_meet_count +1u8;
                    }

                    if(temp_ticket_purchase.red_ball_2==red_ball_1 || temp_ticket_purchase.red_ball_2==red_ball_2 ||  temp_ticket_purchase.red_ball_2==red_ball_3 ||  temp_ticket_purchase.red_ball_2==red_ball_4 ||  temp_ticket_purchase.red_ball_2==red_ball_5 ||  temp_ticket_purchase.red_ball_2==red_ball_6) {
                         red_meet_count = red_meet_count +1u8;
                    }
                    
                    if(temp_ticket_purchase.red_ball_3==red_ball_1 || temp_ticket_purchase.red_ball_3==red_ball_2 ||  temp_ticket_purchase.red_ball_3==red_ball_3 ||  temp_ticket_purchase.red_ball_3==red_ball_4 ||  temp_ticket_purchase.red_ball_3==red_ball_5 ||  temp_ticket_purchase.red_ball_3==red_ball_6) {
                         red_meet_count = red_meet_count +1u8;
                    }
                    
                    if(temp_ticket_purchase.red_ball_4==red_ball_1 || temp_ticket_purchase.red_ball_4==red_ball_2 ||  temp_ticket_purchase.red_ball_4==red_ball_3 ||  temp_ticket_purchase.red_ball_4==red_ball_4 ||  temp_ticket_purchase.red_ball_4==red_ball_5 ||  temp_ticket_purchase.red_ball_4==red_ball_6) {
                         red_meet_count = red_meet_count +1u8;
                    }
                    
                    if(temp_ticket_purchase.red_ball_5==red_ball_1 || temp_ticket_purchase.red_ball_5==red_ball_2 ||  temp_ticket_purchase.red_ball_5==red_ball_3 ||  temp_ticket_purchase.red_ball_5==red_ball_4 ||  temp_ticket_purchase.red_ball_5==red_ball_5 ||  temp_ticket_purchase.red_ball_5==red_ball_6) {
                         red_meet_count = red_meet_count +1u8;
                    }
                    
                    if(temp_ticket_purchase.red_ball_6==red_ball_1 || temp_ticket_purchase.red_ball_6==red_ball_2 ||  temp_ticket_purchase.red_ball_6==red_ball_3 ||  temp_ticket_purchase.red_ball_6==red_ball_4 ||  temp_ticket_purchase.red_ball_6==red_ball_5 ||  temp_ticket_purchase.red_ball_6==red_ball_6) {
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
                    if(temp_ticket_purchase.red_ball_1==red_ball_1 || temp_ticket_purchase.red_ball_1==red_ball_2 ||  temp_ticket_purchase.red_ball_1==red_ball_3 ||  temp_ticket_purchase.red_ball_1==red_ball_4 ||  temp_ticket_purchase.red_ball_1==red_ball_5 ||  temp_ticket_purchase.red_ball_1==red_ball_6) {
                         red_meet_count = red_meet_count +1u8;
                    }
                    

                    if(temp_ticket_purchase.red_ball_2==red_ball_1 || temp_ticket_purchase.red_ball_2==red_ball_2 ||  temp_ticket_purchase.red_ball_2==red_ball_3 ||  temp_ticket_purchase.red_ball_2==red_ball_4 ||  temp_ticket_purchase.red_ball_2==red_ball_5 ||  temp_ticket_purchase.red_ball_2==red_ball_6) {
                         red_meet_count = red_meet_count +1u8;
                    }
                    
                    if(temp_ticket_purchase.red_ball_3==red_ball_1 || temp_ticket_purchase.red_ball_3==red_ball_2 ||  temp_ticket_purchase.red_ball_3==red_ball_3 ||  temp_ticket_purchase.red_ball_3==red_ball_4 ||  temp_ticket_purchase.red_ball_3==red_ball_5 ||  temp_ticket_purchase.red_ball_3==red_ball_6) {
                         red_meet_count = red_meet_count +1u8;
                    }
                    
                    if(temp_ticket_purchase.red_ball_4==red_ball_1 || temp_ticket_purchase.red_ball_4==red_ball_2 ||  temp_ticket_purchase.red_ball_4==red_ball_3 ||  temp_ticket_purchase.red_ball_4==red_ball_4 ||  temp_ticket_purchase.red_ball_4==red_ball_5 ||  temp_ticket_purchase.red_ball_4==red_ball_6) {
                         red_meet_count = red_meet_count +1u8;
                    }
                    
                    if(temp_ticket_purchase.red_ball_5==red_ball_1 || temp_ticket_purchase.red_ball_5==red_ball_2 ||  temp_ticket_purchase.red_ball_5==red_ball_3 ||  temp_ticket_purchase.red_ball_5==red_ball_4 ||  temp_ticket_purchase.red_ball_5==red_ball_5 ||  temp_ticket_purchase.red_ball_5==red_ball_6) {
                         red_meet_count = red_meet_count +1u8;
                    }
                    
                    if(temp_ticket_purchase.red_ball_6==red_ball_1 || temp_ticket_purchase.red_ball_6==red_ball_2 ||  temp_ticket_purchase.red_ball_6==red_ball_3 ||  temp_ticket_purchase.red_ball_6==red_ball_4 ||  temp_ticket_purchase.red_ball_6==red_ball_5 ||  temp_ticket_purchase.red_ball_6==red_ball_6) {
                         red_meet_count = red_meet_count +1u8;
                    }

                    if (red_meet_count>=3u8) {
                        cur_prize = 2u8;
                    } else if (red_meet_count >=2u8) {
                        cur_prize = 3u8;
                    }
                }
                
                // TODO 目前leo还不支持for里用set，等更新吧 写不动了


                if (cur_prize == 1u8) {

                    if(first_price.index>1u32) {
                        let price_info:TicketPurchasePriceInfo = TicketPurchasePriceInfo {
                            user: temp_ticket_purchase.user,
                            round_number: temp_ticket_purchase.round_number, 
                            count:temp_ticket_purchase.count, 
                            gates: temp_ticket_purchase.gates,
                            red_ball_1: temp_ticket_purchase.red_ball_1,
                            red_ball_2: temp_ticket_purchase.red_ball_2,
                            red_ball_3: temp_ticket_purchase.red_ball_3,
                            red_ball_4: temp_ticket_purchase.red_ball_4,
                            red_ball_5: temp_ticket_purchase.red_ball_5,
                            red_ball_6: temp_ticket_purchase.red_ball_6,
                            blue_ball_1: temp_ticket_purchase.blue_ball_1,
                            reward:0u64,
                            index:1u32
                        };
                        // 第一名
                        first_price = price_info;
                    } else {
                        // 尝试是否能当第二名
                        if(second_price.index>1u32) {
                            let price_info:TicketPurchasePriceInfo = TicketPurchasePriceInfo {
                                user: temp_ticket_purchase.user,
                                round_number: temp_ticket_purchase.round_number, 
                                count:temp_ticket_purchase.count, 
                                gates: temp_ticket_purchase.gates,
                                red_ball_1: temp_ticket_purchase.red_ball_1,
                                red_ball_2: temp_ticket_purchase.red_ball_2,
                                red_ball_3: temp_ticket_purchase.red_ball_3,
                                red_ball_4: temp_ticket_purchase.red_ball_4,
                                red_ball_5: temp_ticket_purchase.red_ball_5,
                                red_ball_6: temp_ticket_purchase.red_ball_6,
                                blue_ball_1: temp_ticket_purchase.blue_ball_1,
                                reward:0u64,
                                index:1u32
                            };
                            // 第二名变为第三名
                            third_price = second_price;
                            second_price = price_info;
                        } else {
                            // 尝试三等奖
                            if(third_price.index>1u32) {
                                let price_info:TicketPurchasePriceInfo = TicketPurchasePriceInfo {
                                    user: temp_ticket_purchase.user,
                                    round_number: temp_ticket_purchase.round_number, 
                                    count:temp_ticket_purchase.count, 
                                    gates: temp_ticket_purchase.gates,
                                    red_ball_1: temp_ticket_purchase.red_ball_1,
                                    red_ball_2: temp_ticket_purchase.red_ball_2,
                                    red_ball_3: temp_ticket_purchase.red_ball_3,
                                    red_ball_4: temp_ticket_purchase.red_ball_4,
                                    red_ball_5: temp_ticket_purchase.red_ball_5,
                                    red_ball_6: temp_ticket_purchase.red_ball_6,
                                    blue_ball_1: temp_ticket_purchase.blue_ball_1,
                                    reward:0u64,
                                    index:1u32
                                };
                                // 第三名
                                first_price = price_info;
                                finish_flag_1 = true; 
                            } else {
                                // 第三名也是一等奖
                                 finish_flag_1 = true; 
                            }
                        }
                    }
                } 


                if (cur_prize == 2u8) {

                    // 尝试是否能当第二名
                    if(second_price.index>2u32) {
                        let price_info:TicketPurchasePriceInfo = TicketPurchasePriceInfo {
                            user: temp_ticket_purchase.user,
                            round_number: temp_ticket_purchase.round_number, 
                            count:temp_ticket_purchase.count, 
                            gates: temp_ticket_purchase.gates,
                            red_ball_1: temp_ticket_purchase.red_ball_1,
                            red_ball_2: temp_ticket_purchase.red_ball_2,
                            red_ball_3: temp_ticket_purchase.red_ball_3,
                            red_ball_4: temp_ticket_purchase.red_ball_4,
                            red_ball_5: temp_ticket_purchase.red_ball_5,
                            red_ball_6: temp_ticket_purchase.red_ball_6,
                            blue_ball_1: temp_ticket_purchase.blue_ball_1,
                            reward:0u64,
                            index:2u32
                        };
                        // 第二名变为第三名
                        third_price = second_price;
                        second_price = price_info;
                    } else {
                        // 尝试三等奖
                        if(third_price.index>2u32) {
                            let price_info:TicketPurchasePriceInfo = TicketPurchasePriceInfo {
                                user: temp_ticket_purchase.user,
                                round_number: temp_ticket_purchase.round_number, 
                                count:temp_ticket_purchase.count, 
                                gates: temp_ticket_purchase.gates,
                                red_ball_1: temp_ticket_purchase.red_ball_1,
                                red_ball_2: temp_ticket_purchase.red_ball_2,
                                red_ball_3: temp_ticket_purchase.red_ball_3,
                                red_ball_4: temp_ticket_purchase.red_ball_4,
                                red_ball_5: temp_ticket_purchase.red_ball_5,
                                red_ball_6: temp_ticket_purchase.red_ball_6,
                                blue_ball_1: temp_ticket_purchase.blue_ball_1,
                                reward:0u64,
                                index:2u32
                            };
                            // 第三名
                            four_price = third_price;
                            third_price = price_info;
                        } else {
                            // 尝试四等奖
                            if(four_price.index>2u32) {
                                let price_info:TicketPurchasePriceInfo = TicketPurchasePriceInfo {
                                    user: temp_ticket_purchase.user,
                                    round_number: temp_ticket_purchase.round_number, 
                                    count:temp_ticket_purchase.count, 
                                    gates: temp_ticket_purchase.gates,
                                    red_ball_1: temp_ticket_purchase.red_ball_1,
                                    red_ball_2: temp_ticket_purchase.red_ball_2,
                                    red_ball_3: temp_ticket_purchase.red_ball_3,
                                    red_ball_4: temp_ticket_purchase.red_ball_4,
                                    red_ball_5: temp_ticket_purchase.red_ball_5,
                                    red_ball_6: temp_ticket_purchase.red_ball_6,
                                    blue_ball_1: temp_ticket_purchase.blue_ball_1,
                                    reward:0u64,
                                    index:2u32
                                };
                                // 第三名
                                five_price = four_price;
                                four_price = price_info;
                            } else {
                                // 前三名必须是大于二等奖的才行
                            }
                        }
                    }
                    
                } 


                if (cur_prize == 3u8) {

                    // 尝试三等奖
                    if(third_price.index>3u32) {
                        let price_info:TicketPurchasePriceInfo = TicketPurchasePriceInfo {
                            user: temp_ticket_purchase.user,
                            round_number: temp_ticket_purchase.round_number, 
                            count:temp_ticket_purchase.count, 
                            gates: temp_ticket_purchase.gates,
                            red_ball_1: temp_ticket_purchase.red_ball_1,
                            red_ball_2: temp_ticket_purchase.red_ball_2,
                            red_ball_3: temp_ticket_purchase.red_ball_3,
                            red_ball_4: temp_ticket_purchase.red_ball_4,
                            red_ball_5: temp_ticket_purchase.red_ball_5,
                            red_ball_6: temp_ticket_purchase.red_ball_6,
                            blue_ball_1: temp_ticket_purchase.blue_ball_1,
                            reward:0u64,
                            index:3u32
                        };
                        // 第三名
                        four_price = third_price;
                        third_price = price_info;
                    } else {
                        // 尝试四等奖
                        if(four_price.index>3u32) {
                            let price_info:TicketPurchasePriceInfo = TicketPurchasePriceInfo {
                                user: temp_ticket_purchase.user,
                                round_number: temp_ticket_purchase.round_number, 
                                count:temp_ticket_purchase.count, 
                                gates: temp_ticket_purchase.gates,
                                red_ball_1: temp_ticket_purchase.red_ball_1,
                                red_ball_2: temp_ticket_purchase.red_ball_2,
                                red_ball_3: temp_ticket_purchase.red_ball_3,
                                red_ball_4: temp_ticket_purchase.red_ball_4,
                                red_ball_5: temp_ticket_purchase.red_ball_5,
                                red_ball_6: temp_ticket_purchase.red_ball_6,
                                blue_ball_1: temp_ticket_purchase.blue_ball_1,
                                reward:0u64,
                                index:3u32
                            };
                            // 第四名
                            five_price = four_price;
                            four_price = price_info;
                        } else {
                            // 尝试五等奖
                            if(five_price.index>3u32) {
                                let price_info:TicketPurchasePriceInfo = TicketPurchasePriceInfo {
                                    user: temp_ticket_purchase.user,
                                    round_number: temp_ticket_purchase.round_number, 
                                    count:temp_ticket_purchase.count, 
                                    gates: temp_ticket_purchase.gates,
                                    red_ball_1: temp_ticket_purchase.red_ball_1,
                                    red_ball_2: temp_ticket_purchase.red_ball_2,
                                    red_ball_3: temp_ticket_purchase.red_ball_3,
                                    red_ball_4: temp_ticket_purchase.red_ball_4,
                                    red_ball_5: temp_ticket_purchase.red_ball_5,
                                    red_ball_6: temp_ticket_purchase.red_ball_6,
                                    blue_ball_1: temp_ticket_purchase.blue_ball_1,
                                    reward:0u64,
                                    index:3u32
                                };
                                // 第五名
                                five_price = price_info;
                            } else {
                            }
                        }
                    }
                }

            }
        }


        let first_reward:u64 = 0u64;
        let second_reward:u64 = 0u64;
        let third_reward:u64 = 0u64;


        let first_total_price_amount:u64 = current_prize_pool.money*(70u64/100u64)*(80u64/100u64);
        let second_total_price_amount:u64 = current_prize_pool.money*(70u64/100u64)*(15u64/100u64);
        let third_total_price_amount:u64 = current_prize_pool.money*(70u64/100u64)*(5u64/100u64);

        if (first_price.index == 1u32) {
            if (first_price.index == 1u32 && second_price.index==10u32 && third_price.index==10u32)  {
                first_reward = first_total_price_amount;
            } 

            if (first_price.index == 1u32 && second_price.index==1u32 && third_price.index==10u32)  {
                first_reward = first_total_price_amount*1u64/2u64;
                second_reward = first_total_price_amount*1u64/2u64;
            } 

            if (first_price.index == 1u32 && second_price.index==1u32 && third_price.index==1u32)  {
                first_reward = first_total_price_amount*1u64/3u64;
                second_reward = first_total_price_amount*1u64/3u64;
                third_reward = first_total_price_amount*1u64/3u64;
            } 
        
            if (first_price.index == 1u32 && second_price.index==1u32 && third_price.index==2u32)  {
                first_reward = first_total_price_amount*1u64/2u64;
                second_reward = first_total_price_amount*1u64/2u64;
                third_reward = second_total_price_amount;
            } 

            if (first_price.index == 1u32 && second_price.index==1u32 && third_price.index==3u32)  {
                first_reward = first_total_price_amount*1u64/2u64;
                second_reward = first_total_price_amount*1u64/2u64;
                third_reward = third_total_price_amount;
            } 

            if (first_price.index == 1u32 && second_price.index==2u32 && third_price.index==10u32)  {
                first_reward = first_total_price_amount;
                second_reward = second_total_price_amount;
            } 

            if (first_price.index == 1u32 && second_price.index==2u32 && third_price.index==2u32)  {
                first_reward = first_total_price_amount;
                second_reward = second_total_price_amount*1u64/2u64;
                third_reward = second_total_price_amount*1u64/2u64;
            } 
            if (first_price.index == 1u32 && second_price.index==2u32 && third_price.index==3u32)  {
                first_reward = first_total_price_amount;
                second_reward = second_total_price_amount;
                third_reward = third_total_price_amount;
            } 

            if (first_price.index == 1u32 && second_price.index==3u32 && third_price.index==0u32)  {
                first_reward = first_total_price_amount;
                second_reward = third_total_price_amount;
            } 

            if (first_price.index == 1u32 && second_price.index==3u32 && third_price.index==3u32)  {
                first_reward = first_total_price_amount;
                second_reward = third_total_price_amount*1u64/2u64;
                third_reward = third_total_price_amount*1u64/2u64;
            } 
        } else {
            // 无一等奖中奖
            // 有二等奖中奖
            if(second_price.index == 2u32) {
                if (second_price.index == 2u32 && third_price.index==10u32 && four_price.index==10u32)  {
                    first_reward = second_total_price_amount;
                } 
                if (second_price.index == 2u32 && third_price.index==2u32 && four_price.index==10u32)  {
                    first_reward = second_total_price_amount*1u64/2u64;
                    second_reward = second_total_price_amount*1u64/2u64;
                } 
                if (second_price.index == 2u32 && third_price.index==2u32 && four_price.index==2u32)  {
                    first_reward = second_total_price_amount*1u64/3u64;
                    second_reward = second_total_price_amount*1u64/3u64;
                    third_reward = second_total_price_amount*1u64/3u64;
                } 
                if (second_price.index == 2u32 && third_price.index==2u32 && four_price.index==3u32)  {
                    first_reward = second_total_price_amount*1u64/2u64;
                    second_reward = second_total_price_amount*1u64/2u64;
                    third_reward = third_total_price_amount*1u64/3u64;
                } 
                if (second_price.index == 2u32 && third_price.index==3u32 && four_price.index==10u32)  {
                    first_reward = second_total_price_amount;
                    second_reward = third_total_price_amount;
                } 
                if (second_price.index == 2u32 && third_price.index==3u32 && four_price.index==3u32)  {
                    first_reward = second_total_price_amount;
                    second_reward = third_total_price_amount*1u64/2u64;
                    third_reward = third_total_price_amount*1u64/2u64;
                } 
            } else {
                // 无二等奖中奖
                // 有三等奖中奖
                if(third_price.index == 3u32) {
                    if (third_price.index == 3u32 && four_price.index==10u32 && five_price.index==10u32)  {
                        first_reward = third_total_price_amount;
                    } 
                    if (third_price.index == 3u32 && four_price.index==3u32 && five_price.index==10u32)  {
                        first_reward = third_total_price_amount*1u64/2u64;
                        second_reward =  third_total_price_amount*1u64/2u64;
                    } 
                    if (third_price.index == 3u32 && four_price.index==3u32 && five_price.index==3u32)  {
                        first_reward = third_total_price_amount*1u64/3u64;
                        second_reward=third_total_price_amount*1u64/3u64;
                        third_reward=third_total_price_amount*1u64/3u64;
                    } 
                } 
            }
        }

        // 更新轮次状态和资金池剩余金额
        let left_money:u64 = current_prize_pool.money - first_reward-second_reward-third_reward;
        let update_prize_pool:PrizePool = PrizePool{
            money:left_money,
            current_round:current_prize_pool.current_round,
            current_round_status:3u8,
            current_round_num:current_prize_pool.current_round_num,
        };
        Mapping::set(currentPrizePoolMap,1u8,update_prize_pool);
    }

}
