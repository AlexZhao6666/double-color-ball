# 基于leo语言实现的双色球
## 一、游戏介绍：
### 1.玩法
- 1.开启一期双色球
- 2.用户可以投注(33选6红,16选1蓝)
- 3.系统停止投注
- 4.系统开奖-用户根据开奖情况获取奖励

### 2.奖项规则：
TODO:为了测试提高中奖概率，目前还未实现完整版双色球，目前的奖励规则是:
- 一等奖【1蓝、3红】（所有一等奖平分奖池70%的80%）
- 二等奖【1蓝、1红】||【3红】（所有一等奖平分奖池70%的20%）

### 3.中奖名额
###【每期两个中奖名额】TODO:等leo支持数组后，可以提高中奖名额
按照投注先后顺序，选出两名奖项类别最高的予以颁奖
- 第一获奖者
- 第二获奖者

### 4.举例:
如每注10credit,第一期共10人投注，则奖池总金额为100credit
十人投注顺序分别为：
- A （red:1,2,3,4,5,6 blue:7）
- B （red:2,3,4,5,6,7 blue:8）
- C （red:3,4,5,6,7,8 blue:9）
- D （red:4,5,6,7,8,9 blue:10）
- E （red:5,6,7,8,9,10 blue:11）
- F （red:6,7,8,9,10,11 blue:12）
- G （red:7,8,9,10,11,12 blue:13）
- H （red:8,9,10,11,12,13 blue:14）
- I （red:9,10,11,12,13,14 blue:15）
- J （red:10,11,12,13,14,15 blue:16）

如果第一期开奖号码为:red:4,5,6,7,8,9 blue:9
则:两名得奖人为
- 第一名:C 奖金56credit
- 第二名:A 奖金14credit
奖池剩余30作为后续奖池初始资金

### 二、项目介绍

- contract
  leo编写的aleo链上智能合约
- api-serer
  双色球应用的web后端
- web-server
  双色球应用的web前端

### 三、项目部署
- contract
  直接上链：（snarkos developer deploy double_color_ball.aleo --private-key xxxx --query "https://vm.aleo.org/api" --path "/xxxx/build/" --broadcast "https://vm.aleo.org/api/testnet3/transaction/broadcast" --fee 5000000 --record xxx)

- api-serer
  rust语言编写，
  打包:cargo build --release
  启动:(api-server -- --tx-id xxx可用的transactionIdxxx --api 0.0.0.0:5111 --node-url https://vm.aleo.org/api --snarkos-path /xxxx/snarkos --private-key xxxx)

- web-serer
  部署时记得修改后端url地址，前后端分离，请使用nginx代理做跨域处理.

### 四、项目演示地址
http://121.40.104.60:3033/dcb/index.html
