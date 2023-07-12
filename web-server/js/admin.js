const { createApp } = Vue

// 创建 Axios 实例
const axiosInstance = axios.create();
const apiUrl = "http://192.168.2.28:5111";

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
            alert("网络异常");
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
            loading:false,
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

            axiosInstance.get(apiUrl+"/prizepool").then(data => {
                this.loading = false
                const curPool = data;
                this.curRound = curPool.current_round;
                this.poolMoney = curPool.money;
                if(curPool.current_round_status== 1) {
                    this.curRoundStatus = "投注中";
                } else if (curPool.current_round_status== 2) {
                    this.curRoundStatus = "待开奖";
                } else if (curPool.current_round_status== 3) {
                    this.curRoundStatus = "已开奖";
                }
                this.curRoundNum = curPool.current_round_num;

            }).catch(err => {
                this.loading = false
                alert("网络异常");
            })
        },
        openNewRound() {
            this.loading = true
            axiosInstance.get(apiUrl+"/round/start/"+(this.curRound+1)).then(data => {
                this.loading = false
                alert("开启成功");
                window.location.reload();

            }).catch(err => {
                this.loading = false
                alert("开启失败")
                window.location.reload();
            })
        },
        stopCurRound() {
            this.loading = true
            axiosInstance.get(apiUrl+"/round/stop/"+this.curRound).then(data => {
                this.loading = false
                alert("停止投注成功");
                window.location.reload();

            }).catch(err => {
                this.loading = false
                alert("停止投注失败")
                window.location.reload();
            })
        },
        priceCurRound() {
            this.loading = true
            axiosInstance.get(apiUrl+"/round/drawprice/"+this.curRound).then(data => {
                this.loading = false
                alert("开奖成功");
                window.location.reload();

            }).catch(err => {
                this.loading = false
                alert("开奖失败")
                window.location.reload();
            })
        },
    },
}).use(ElementPlus).mount('#app')
