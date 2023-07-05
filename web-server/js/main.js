const { createApp } = Vue

createApp({
    data() {
        return {
            message: 'Hello Vue!',
            winNumber: '1 2 3 4 5 6 ',
            tableData:[],
            dialogFormVisible:false,
            formLabelWidth:'100px',
            form:{
                name:'',
                address:'',
            }
        }
    },
    mounted() {
        this.getData()
        this.getTable()
    },
    methods: {
        palyNow(){
            this.dialogFormVisible = true
        },
        submitHandler(){
            this.dialogFormVisible = false
            console.log('form',this.form);
        },
        getData(){
            axios({
                url:'http://192.168.3.22:9000/app/v1/currency/list',//在线跨域请求
                method:"GET",//默认是get请求
                // params:{
                //     cityId: 330100,
                //     pageNum: 1,
                //     pageSize: 10,
                //     type: 1,
                //     k: 3969168,
                // }
            }).then(res => {
                console.log(res) // axios会对我们请求来的结果进行再一次的封装（ 让安全性提高 ）
            }).catch(err => {
                console.log(err)
            })
        },
        getTable(){
            this.tableData = [
                {
                    'date': '2016-05-03',
                    'name': 'Tom',
                    'address': 'No. 189, Grove St, Los Angeles',
                },
                {
                    'date': '2016-05-03',
                    'name': 'Lily',
                    'address': 'No. 189, Grove St, Los Angeles',
                },
            ]
        }
    },
}).use(ElementPlus).mount('#app')
  