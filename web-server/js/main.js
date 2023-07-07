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
            },
            redMaxNumb:33, // 遍历红球总数
            redNumbRlue:6, // 默认选6个红球
            blueMaxNumb:16, // 遍历蓝球总数

            selectedRedBallList:[], // 已选红球
            selectedBlueBallList:[], // 已选蓝球
        }
    },
    computed:{
        redInfoList(){
            return this.redInfo.split('  ').filter((i) => {
                return i
            })
        },
    },
    mounted() {
        this.getPricePoolData();
    },
    methods: {
        resetDialog(){
            for (const key in this.form) {
                this.form[key] = ''
            }
            this.selectedRedBallList = []
            this.selectedBlueBallList = []
            this.dialogFormVisible = false
        },
        // 选择红球
        chooeRedBall(n){
            let sl = [...this.selectedRedBallList]
            let hasIt = sl.includes(n)
            if(hasIt){
                sl = sl.filter((item)=>{
                    return item !== n
                })
            }else{
                if(sl.length > (this.redNumbRlue-1)){
                    alert(`红球最多选${this.redNumbRlue}个`)
                    return
                }
                sl.push(n)
            }
            this.selectedRedBallList = sl
        },
        // 选择蓝球
        chooeBlueBall(n){
            let sl = [...this.selectedBlueBallList]
            let hasIt = sl.includes(n)
            if(hasIt){
                sl = sl.filter((item)=>{
                    return item !== n
                })
            }else{
                if(sl.length >0){
                    alert('蓝球最多选1个')
                    return
                }
                sl.push(n)
            }
            this.selectedBlueBallList = sl
        },


        // 是否选过的红球
        hasSelectdRed(numb){
            return this.selectedRedBallList.includes(numb)
        },
        // 是否选过的红球
        hasSelectdBlue(numb){
            return this.selectedBlueBallList.includes(numb)
        },

        palyNow(){
            this.dialogFormVisible = true
        },
        submitHandler(){
            this.dialogFormVisible = false
            console.log('form',this.form);
        },
        getPricePoolData(){
            axiosInstance.get("http://192.168.2.28:5111/prizepool").then(data => {

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
            axiosInstance.get("http://192.168.2.28:5111/lotterydraw/"+this.curRound).then(data => {
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
            axiosInstance.get("http://192.168.2.28:5111/winninglist/"+this.curRound).then(data => {
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
        },
        doTicketPurchase(){

            if(!(this.form.user && this.form.user.length == 63 && this.form.user.includes('aleo'))) {
                return alert("请填写正确的aleo账户地址");
            }
            if(this.selectedRedBallList && (this.selectedRedBallList.length < this.redNumbRlue)){
                return alert(`红球必须选${this.redNumbRlue}个`);
            }
            if(!this.selectedBlueBallList[0]){
                return alert(`蓝球必须选1个`);
            }

            for (let index = 0; index < this.redNumbRlue; index++) {
                this.form['red_ball_'+(index+1)] = Number(this.selectedRedBallList[index])
            }
            this.form.blue_ball_1 = Number(this.selectedBlueBallList[0])
            var data = {
                user:this.form.user,
                round_number:this.curRound,
                count:1,
                gates:100000000,
                ...this.form
            }
            this.loading = true
            axiosInstance.post("http://192.168.2.28:5111/round/ticketpurchase",data,{
                headers: {
                    'Content-Type': 'application/json'
                }
            }).then(data => {
                this.loading = false
                alert('投注成功')
                this.resetDialog()
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
                alert('投注失败')
                this.loading = false
                //alert(JSON.stringify(err));
            })
        },
        isPc(){
            var userAgentInfo = navigator.userAgent;
            var Agents = new Array("Android", "iPhone", "SymbianOS", "Windows Phone", "iPad", "iPod");
            var flag = true;
            for (var v = 0; v < Agents.length; v++) {
                if (userAgentInfo.indexOf(Agents[v]) > 0) { flag = false; break; }
            }
            return flag
        }
    },
}).use(ElementPlus).mount('#app')

