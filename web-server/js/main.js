const { createApp } = Vue

// 创建 Axios 实例
const axiosInstance = axios.create();

// 请求拦截器
axiosInstance.interceptors.request.use(
  function (config) {
    // 在发送请求之前做一些处理
    // 可以修改请求配置，添加头部信息等
    console.log("请求拦截器");
    return config;
  },
  function (error) {
    // 处理请求错误
    return Promise.reject(error);
  }
);

// 响应拦截器
axiosInstance.interceptors.response.use(
  function (response) {
    if(response.status == 200) {
        var data_str = response.data;
        const fieldName = "user";
        data_str = data_str.replace(/(\w+)(?=:)/g, '"$1"').replace(/u64|u32|u8/g, '').replace(
            new RegExp(`"${fieldName}":\\s*([^,}\\s]+)`, "g"),
            `"${fieldName}": "$1"`
          );;
        console.log(data_str)
        var jsonObj = JSON.parse(data_str);
        return jsonObj; 
    } else {
        alert("请求失败");
    }
  },
  function (error) {
    // 处理响应错误
    return Promise.reject(error);
  }
);

function isEmptyObject(obj) {
    return Object.keys(obj).length === 0;
}

createApp({
    data() {
        return {
            message: 'Hello Vue!',
            curRound: 0,
            poolMoney: 0,
            curRoundStatus: 0,
            curRoundNum: 0,
            redInfo:'',
            blueInfo:'',
            winningList:[],
            dialogFormVisible:false,
            formLabelWidth:'100px',
            form:{
                name:'',
                address:'',
            }
        }
    },
    mounted() {
        this.getPricePoolData();
    },
    methods: {
        palyNow(){
            this.dialogFormVisible = true
        },
        submitHandler(){
            this.dialogFormVisible = false
            console.log('form',this.form);
        },
        getPricePoolData(){
            axiosInstance.get("http://127.0.0.1:5111/prizepool").then(data => {

                const curPool = data;
                this.curRound = curPool.current_round;
                this.poolMoney = curPool.money;
                if(curPool.current_round_status== 1) {
                    this.curRoundStatus = "投注中";
                } else if (curPool.current_round_status== 2) {
                    this.curRoundStatus = "待开奖";
                } else if (curPool.current_round_status== 3) {
                    this.curRoundStatus = "已开奖";
                    this.getLotteryDrawingData(); 
                    this.getWinningList();
                }
                this.curRoundNum = curPool.current_round_num;

            }).catch(err => {
                alert("请在本机5111端口启动后端服务")
            })
        },
        getLotteryDrawingData(){
            this.redInfo = '';
            this.blueInfo = '';
            axiosInstance.get("http://127.0.0.1:5111/lotterydraw/"+this.curRound).then(data => {
                var balls = new Array();
                balls.push(parseInt(data.red_ball_1));
                balls.push(parseInt(data.red_ball_2));
                balls.push(parseInt(data.red_ball_3));
                balls.push(parseInt(data.red_ball_4));
                balls.push(parseInt(data.red_ball_5));
                balls.push(parseInt(data.red_ball_6));
                balls = balls.sort((a,b)=>a-b);
                var curRedStr="";
                for(var i of balls) {
                    if(i < 10) {
                        curRedStr = curRedStr+'0'+i+"  ";
                    } else {
                        curRedStr = curRedStr+i+"  ";
                    }
         
                }
                this.redInfo = curRedStr;
                if(data.blue_ball_1 <10) {
                    this.blueInfo = '0'+data.blue_ball_1;
                } else {
                    this.blueInfo = data.blue_ball_1;
                }
    
            }).catch(err => {
                alert("请在本机5111端口启动后端服务")
            })
        },
        getWinningList(){
            axiosInstance.get("http://127.0.0.1:5111/winninglist/"+this.curRound).then(data => {
                if(!isEmptyObject(data)) {
                 
                    if(data.first.index != '10') {
                        this.winningList.push(data.first);
                    }
                    if(data.second.index != '10') {
                        this.winningList.push(data.second);
                    }
                } else {
                    // 无人中奖
                }
    
            }).catch(err => {
                //alert(JSON.stringify(err));
            })
        }
    },
}).use(ElementPlus).mount('#app')

