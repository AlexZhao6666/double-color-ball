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
                user:'',
                red_ball_1:'',
                red_ball_2:'',
                red_ball_3:'',
                red_ball_4:'',
                red_ball_5:'',
                red_ball_6:'',
                blue_ball_1:'',
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
        openNewRound() {
            axiosInstance.get("http://127.0.0.1:5111/round/start/"+(this.curRound+1)).then(data => {

                alert("开启成功");

            }).catch(err => {
                alert("开启失败")
            })      
        },
        stopCurRound() {
            axiosInstance.get("http://127.0.0.1:5111/round/stop/"+this.curRound).then(data => {

                alert("停止投注成功");

            }).catch(err => {
                alert("停止投注失败")
            })      
        },
        priceCurRound() {
            axiosInstance.get("http://127.0.0.1:5111/round/drawprice/"+this.curRound).then(data => {

                alert("开奖成功");

            }).catch(err => {
                alert("开奖失败")
            })      
        },
    },
}).use(ElementPlus).mount('#app')

