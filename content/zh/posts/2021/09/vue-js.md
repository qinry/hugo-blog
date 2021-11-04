---
title: "Vue.js入门"
date: 2021-09-20T06:38:50+08:00
description: "Vue入门学习"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- vue
categories:
- web
---

## 概述

**Vue**，一套用于构建用户界面的渐进式框架，被设计为可以自底向上逐层应用。Vue 的核心库只关注视图层，还支持事件驱动。

**什么是MVVM**

MVVM代表Mode-View-ViewModel，一种软件架构。
* Model：模型层，数据保存
* View：视图层，用户界面
* ViewModel：视图模型层，还可以理解为数据绑定器，负责把Model的数据同步到View显示出来，还负责把View的修改同步回Model。

ViewModel层采用**双向数据绑定**，View发生变动，自动反映ViewModel，反之亦然。ViewModel和Model之间则是双向通信。

![image](../../../../images/posts/2021/09/vue-js/1.png)

Vue可以理解为实现MVVM理念的前端框架。

## 第一个Vue程序

Vue中的data的属性表示模型数据，视图模板中用两个花括号来代表绑定的相应名称的模型数据，也可以是使用`v-`为前缀的指令来绑定数据。

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>

</head>
<body>
<!-- 视图 -->
<div id="app">
    {{message}}
    <span v-bind:title="message">鼠标悬停在这里几秒</span>
</div>

<!-- 1. 导入vue.js    -->
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.14/dist/vue.min.js"></script>
<script>
    // 视图模型
    var vm = new Vue({
        el: "#app",
        data:{ // 模型
            message:"hello,Vue!"
        }
    });
</script>
</body>
</html>
```

显示：
![image](../../../../images/posts/2021/09/vue-js/2.png)

当Model数据发生改变时，ViewModel会同步View的改变，例如在浏览器的控制台修改vm.message的值，反映到视图。

![image](../../../../images/posts/2021/09/vue-js/3.png)

## 基本语法

if-else判断和for循环，指令分别有`v-if`、`v-else-if`、`v-else`和`v-for`

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<div id="app">
    <h2 v-if="type==='A'">A</h2>
    <h2 v-else-if="type==='B'">B</h2>
    <h2 v-else-if="type==='C'">C</h2>
    <h2 v-else>D</h2>
</div>
<div id="app2">
    <li v-for="(item,index) in items">
        {{item.message}}-{{index}}
    </li>
</div>
<!-- 1. 导入vue.js    -->
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.14/dist/vue.min.js"></script>
<script>
    var vm = new Vue({
        el: "#app",
        data: {
            type: 'A'
        }
    });
    var vm2 = new Vue({
        el: "#app2",
        data: {
            items: [
                {message: "foo"},
                {message: "bar"}
            ]
        }
    });
</script>
</body>
</html>
```

显示：
![image](../../../../images/posts/2021/09/vue-js/4.png)

## 绑定事件

vue的methods属性声明了用于绑定事件的方法，使用`v-on:事件`的指令来绑定事件(事件名和jQuery一致)

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<!-- 视图 -->
<div id="app">
    <button v-on:click="sayHi">点我</button>
</div>

<!-- 1. 导入vue.js    -->
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.14/dist/vue.min.js"></script>
<script>
    // 视图模型
    var vm = new Vue({
        el: "#app",
        data: { // 模型
            message: "hello,Vue!"
        },
        methods: {
            sayHi: function() {
                alert('hello, vue!');
            }
        }
    });
</script>
</body>
</html>
```

显示：
![image](../../../../images/posts/2021/09/vue-js/5.png)

## 数据双向绑定

使用`v-model`指令绑定表单的输入域

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<!-- 视图 -->
<div id="app">
    <input type="uname" name="text" v-model="message">
    {{message}} <br>
    <select name="option" v-model="selected">
        <option value="" disabled>--请选择--</option>
        <option value="A">A</option>
        <option value="B">B</option>
    </select>
    {{selected}} <br>
    <input type="radio" name="sex" value="男" v-model="sex" >男
    <input type="radio" name="sex" value="女" v-model="sex" >女
    {{sex}}<br>
    <textarea name="info" id="" cols="30" rows="10" v-model="textarea" style="resize:none;"></textarea>
    {{textarea}} <br>
</div>

<!-- 1. 导入vue.js    -->
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.14/dist/vue.min.js"></script>
<script>
    // 视图模型
    var vm = new Vue({
        el: "#app",
        data: { // 模型
            message: 'hello,Vue!',
            selected: '',
            sex: '男',
            textarea: '123'
        },
    });
</script>
</body>
</html>
```

![image](../../../../images/posts/2021/09/vue-js/6.png)


## vue组件

组件可设置名称，如名为list，使用组件与使用标签一样。组件的模版与普通vue视图编写一致。还有props属性用于组件的数据绑定。`v-bind:item`与props属性数组中`item`直接相关，模板中`{{item}}`也与props中的`item`相关。

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>vue-component</title>
</head>
<body>
<!-- 视图 -->
<div id="app">
    <list
        v-for="item in items"
        v-bind:item="item"
    ></list>
</div>

<!-- 1. 导入vue.js    -->
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.14/dist/vue.min.js"></script>
<script>
    // vue 组件
    Vue.component('list', {
        props: ['item'],
        template: '<li>{{item}}</li>'
    });
    // 视图模型
    var vm = new Vue({
        el: "#app",
        data: { // 模型
            items: ['Java', 'JavaScript', 'C']
        },
    });
</script>
</body>
</html>
```

![image](../../../../images/posts/2021/09/vue-js/7.png)


## axios通信

要导入vue文件后，导入axios文件。vue对象具有生命周期，其中许多钩子函数，例如beforeCreate、mounted等等。mounted函数用于一次ajax的请求。[详情 axios-js](http://axios-js.com/zh-cn/docs/index.html)

GET请求语法，如下：
```
axios.get('/getUser',{id:1})
    .then(response=>{console.log(response)})
    .catch(error=>{console.log(error)});
```

POST类似。

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>axios</title>
    <style>
        /* 解决闪烁问题 */
        [v-clock] {
            display: none;
        }
    </style>
</head>
<body>
<!-- 视图 -->
<div id="vue" v-clock>
    <h2>{{info.name}}</h2>
    <a v-bind:href="info.url">百度一下</a>
    <p>{{info.description}}</p>
</div>

<!-- 1. 导入vue.js    -->
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.14/dist/vue.min.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script>

    // 视图模型
    var vm = new Vue({
        el: "#vue",
        data() {
            return { info:{} }
        },
        mounted() {
            axios.get('../data.json').then(response=>(this.info=response.data))
        }
    });
</script>
</body>
</html>
```

```
{
  "name": "百度",
  "url": "https://www.baidu.com",
  "description": "有问题找度娘"
}
```

![image](../../../../images/posts/2021/09/vue-js/8.png)

## 计算属性

computed属性与methods属性的写法一致，但有区别，使用methods不会缓存计算结果，而computed则会缓存结果。在浏览器控制台每调用一次`vm.currentTime1()`会产生不同结果，而`vm.currentTime2`则每次调用结果都与第一次的结果是一样，除非起内部的方法里字段发生修改或页面刷新。

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>computed</title>
</head>
<body>
<!-- 视图 -->
<div id="app">
    <p>currentTime1 {{currentTime1()}}</p>
    <p>currentTime2 {{currentTime2}}</p>
</div>

<!-- 1. 导入vue.js    -->
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.14/dist/vue.min.js"></script>
<script>
    // 视图模型
    var vm = new Vue({
        el: "#app",
        data: {
            message: "Hello, Vue!"
        }
        methods: {
            currentTime1: function() {
                return Date.now();
            }
        },
        computed: {
            currentTime2: function() {
                return Date.now();
            }
        }
    });
</script>
</body>
</html>
```

## 插槽

模板需要指定slot属性，组件中template属性内部slot标签需要指定name。通过使用插槽，使得模板视图更加灵活，不嵌入静态数据。

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>slot</title>
</head>
<body>
<div id="app">
    <todo>
        <todo-title slot="todo-title" :title="title"></todo-title>
        <todo-list slot="todo-list" v-for="item in items" :item="item"></todo-list>
    </todo>
</div>
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.14/dist/vue.min.js"></script>
<script>
    Vue.component('todo', {
        template: '<div>' +
            '<slot name="todo-title"></slot>' +
            '<ul>' +
            '<slot name="todo-list"></slot>' +
            '</ul>' +
            '</div>'
    });
    Vue.component('todo-title', {
        props: ['title'],
        template: '<div>{{title}}</div>'
    });
    Vue.component('todo-list', {
        props: ['item'],
        template: '<li>{{item}}</li>'
    });
    var vm = new Vue({
        el: '#app',
        data: {
            title: '编程语言',
            items: ['Java', 'JavaScript', 'C']
        }
    });
</script>
</body>
</html>
```

## 自定义事件内容分发

组件要自删除的按钮的实现，需要自定义事件内容分发来完成。Vue对象是直接参与模型数据删除，其方法为removeItems。组件需要监听鼠标点击事件，触发remove方法。remove方法再通过调用特殊函数`this.$emit('自定义事件名称', 参数列表)`，这个自定义事件还需要模板绑定自定义事件，自定义事件触发的方法正是直接参与删除的removeItems，比如：`@removeItems="removeItems(idx)"`。

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>custom-event-content-deliver</title>
</head>
<body>
<div id="app">
    <todo>
        <todo-title slot="todo-title" :title="title"></todo-title>
        <todo-list slot="todo-list" v-for="(item, idx) in items"
                   :item="item" :idx="idx" @removeItems="removeItems(idx)"
        ></todo-list>
    </todo>
</div>
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.14/dist/vue.min.js"></script>
<script>
    Vue.component('todo', {
        template: '<div>' +
            '<slot name="todo-title"></slot>' +
            '<ul>' +
            '<slot name="todo-list"></slot>' +
            '</ul>' +
            '</div>'
    });
    Vue.component('todo-title', {
        props: ['title'],
        template: '<div>{{title}}</div>'
    });
    Vue.component('todo-list', {
        props: ['item', 'idx'],
        template: '<li>{{idx}}--{{item}} <button @click="remove">删除</button></li>',
        methods: {
            remove: function (idx) {
                this.$emit('removeItems', idx);
            }
        }
    });
    var vm = new Vue({
        el: '#app',
        data: {
            title: '编程语言',
            items: ['Java', 'JavaScript', 'C']
        },
        methods: {
            removeItems: function (idx) {
                console.log('删除了' + this.items[idx] + ' OK');
                this.items.splice(idx, 1);
            }
        }
    });
</script>
</body>
</html>
```

总之，组件的点击删除事件需要委托给自定义事件removeItems

## vue-cli

使用vue-cli之前需要[安装nodejs](https://nodejs.org/zh-cn/)，根据平台安装最近的长期维护版本。

安装后，测试

```
node -v
npm -v
```

成功则显示：

![image](../../../../images/posts/2021/09/vue-js/9.png)

然后使用 npm 这个包管理工具，下载相应的前端模块化工具，需要以管理员权限运行：

```
npm install vue-cli -g
npm install cnpm -g # cnpm是下载淘宝镜像npm包的工具
```

同样测试 vue-cli 是否安装成功：

```
vue list
```
显示：

![image](../../../../images/posts/2021/09/vue-js/10.png)

接着使用 vue-cli 初始化一个 vue.js项目

```
cd ~/Desktop
mkdir vue
cd vue
vue init webpack myvue
```

创建项目时，如果会出现一些输入时，则默认回车，如果出现一些选项，统统按n回车，还有选择编译器时选择运行时加编译器。

下一步是以开发模式启动项目
```
cd myvue
npm install
npm audit fix
npm run dev
```

打开浏览器，输入localhost:8080，查看
![image](../../../../images/posts/2021/09/vue-js/11.png)

查看myvue项目的目录结构，本质也是一个webpack目录结构

![image](../../../../images/posts/2021/09/vue-js/12.png)

简单了解重要目录与文件：

* src：项目源代码编写的地方
* static：存放静态资源，例如html、css、json、图片等等
* node_modules：项目依赖库
* build：webpack的相关文件存放的地方
* config：项目开发环境的配置文件
* index.html：项目的入口页面
* package.json：项目打包的配置文件

详情见[Project Structure](http://vuejs-templates.github.io/webpack/structure.html)

## webpack

安装webpack

```
sudo npm install webpack webpack-cli -g
webpack -v
webpack-cli -v
```
结果：
![image](../../../../images/posts/2021/09/vue-js/13.png)

创建第一个webpack项目

```
cd ~/Desktop
mkdir webpack-study && cd webpack-study
mkdir modules
cd modules
touch main.js
touch hello.js
cd ../
touch webpack.config.js
touch index.html
```

hello.js

```
"use strict";
export function sayHi() {
    document.write("<h2>Hello, World!</h2>")
}
```

main.js

```
'use strict';
import * as hello from './hello';
hello.sayHi();
```

webpack.config.js

```
module.exports = {
    entry: "./modules/main.js",
    output: {
        filename: "./js/bundle.js"
    }
}
```

然后运行webpack命令，输出dist/js/bundle.js

index.html

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>webpack-study</title>
</head>
<body>
<script src="./dist/js/bundle.js"></script>
</body>
</html>
```

结果：
![image](../../../../images/posts/2021/09/vue-js/14.png)

## vue-router


创建一个vue-cli项目，项目名不为vue-router

在**当前项目**下，安装vue-router插件

```
sudo npm install vue-router --save-dev
```

在src下创建文件夹router，这里存放路由配置

router/index.js

```
import Vue from 'vue';
import VueRouter from "vue-router";

import Content from '../components/Content';
import Main from '../components/Main'
// 安装路由
Vue.use(VueRouter)

// 配置导出路由
export default new VueRouter ({
  routes: [
    {
      // 路径
      path: '/content',
      name: 'content',
      // 跳转组件
      component: Content
    },
    {
      // 路径
      path: '/main',
      name: 'main',
      // 跳转组件
      component: Main
    }
  ]
});
```

接着编写，路由组件

components/Main.vue

```
<template>
  <h2>首页</h2>
</template>

<script>
export default {
  name: "Main"
}
</script>

<style scoped>

</style>

```

components/Content.vue

```
<template>
  <h2>内容页</h2>
</template>

<script>
export default {
  name: "Content"
}
</script>

<style scoped>

</style>

```

在main.js中引入router的相关配置

```
import Vue from 'vue'
import App from './App'
// 导入路由配置
import router from './router'

Vue.config.productionTip = false

new Vue({
  el: '#app',
  router, // 使用路由
  components: { App },
  template: '<App/>'
})

```

最后，在App.vue编写模板

```
<template>
  <div id="app">
    <h2>Vue-Router</h2>
    <router-link to="/main">首页</router-link>
    <router-link to="/content">内容页</router-link>
    <router-view></router-view>
  </div>
</template>

<script>

export default {
  name: 'App',
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>

```

`npm run dev` 运行查看效果效果：

![image](../../../../images/posts/2021/09/vue-js/15.png)
![image](../../../../images/posts/2021/09/vue-js/16.png)
![image](../../../../images/posts/2021/09/vue-js/17.png)


## elementUI

在新的vue-cli项目中，安装element-ui插件

```
sudo npm install vue-router --save-dev
sudo npm i element-ui -S
# 安装依赖
sudo npm install
# 安装 sass-loader 和 node-sass
sudo cnpm install sass-loader node-sass --save-dev
# 启动测试
npm run dev
```

首先编写视图，在src下创建views文件夹

views/Main.vue

```
<template>
  <h2>主页</h2>
</template>

<script>
export default {
  name: "Main"
}
</script>

<style scoped>

</style>
```

views/Login.vue

```
<template>
  <div>
    <el-form ref="loginForm" :model="form" :rules="rules" label-width="80px" class="login-box">
      <h3 class="login-title">欢迎登录</h3>
      <el-form-item label="账号" prop="username">
        <el-input type="text" placeholder="请输入账号" v-model="form.username"></el-input>
      </el-form-item>
      <el-form-item label="密码" prop="password">
        <el-input type="password" placeholder="请输入密码" v-model="form.password"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="onSubmit('loginForm')">提交</el-button>
      </el-form-item>
    </el-form>
    <el-dialog
      title="温馨提示"
      :visible.sync="dialogVisible"
      width="30%">
      <span>请输入账号和密码</span>
      <span slot="footer" class="el-dialog__footer">
        <el-button type="primary" @click="dialogVisible = false">确定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: "Login",
  data() {
    return {
      form: {
        username: '',
        password: ''
      },
      rules: {
        username: [
          {required: true, message: '账号不为空', trigger: 'blur'}
        ],
        password: [
          {required: true, message: '密码不为空', trigger: 'blur'}
        ]
      },
      dialogVisible: false
    }
  },
  methods: {
    onSubmit(formName) {
      this.$refs[formName].validate((valid) => {
        if (valid) {
          this.$router.push('/main');
        } else {
          this.dialogVisible = true;
          return false;
        }
      });
    }
  }
}
</script>

<style scoped>
.login-box {
  border: 1px solid #DCDFE6;
  width: 350px;
  margin: 180px auto;
  padding: 35px 35px 15px 35px;
  border-radius: 5px;
  -webkit-border-radius: 5px;
  -moz-border-radius: 5px;
  box-shadow: 0 0 25px #909399;
}

.login-title {
  text-align: center;
  margin: 0 auto 40px auto;
  color: #303133;
}
</style>
```

接着，编写路由相关配置

router/index.js
```
import Vue from 'vue';
import Router from "vue-router";
import Main from "../views/Main";
import Login from "../views/Login";

// 安装路由
Vue.use(Router);    

// 配置导出路由
export default new Router({
  routes: [
    {
      path: '/main',
      name: 'main',
      component: Main
    },
    {
      path: '/login',
      name: 'login',
      component: Login
    }
  ]
});
```

最后，导入Element-UI并使用

main.js
```
import Vue from 'vue'
// 导入ElementUI相关的库
import ElementUI from 'element-ui';
import 'element-ui/lib/theme-chalk/index.css';

import App from './App';
import router from './router';

Vue.use(ElementUI); // Vue使用ElementUI

new Vue({
  el: '#app',
  router,
  render: h => h(App) // 在App中渲染ElementUI的组件
})

```

![image](../../../../images/posts/2021/09/vue-js/18.png)

更多ElementUI组件见，[点这里](https://element.eleme.cn/#/zh-CN/guide/design)


## 嵌套路由

在views下，增加user目录，里面再新增Profile.vue和List.vue

Profile.vue

```
<template>
  <h2>个人信息</h2>
</template>

<script>
export default {
  name: "UserProfile"
}
</script>

<style scoped>

</style>
```

List.vue
```
<template>
  <h2>用户列表</h2>
</template>

<script>
export default {
  name: "UserList"
}
</script>

<style scoped>

</style>
```

修改views/Main.vue

views/Main.vue

```
<template>
  <div>
    <el-container>
      <el-aside width="200px">
        <el-menu :default-openeds="['1']">
          <el-submenu index="1">
            <template slot="title"><i class="el-icon-caret-right"></i>用户管理</template>
            <el-menu-item-group>
              <el-menu-item index="1-1">
                <!--插入的地方-->
                <router-link to="/user/profile">个人信息</router-link>
              </el-menu-item>
              <el-menu-item index="1-2">
                <!--插入的地方-->
                <router-link to="/user/list">用户列表</router-link>
              </el-menu-item>
            </el-menu-item-group>
          </el-submenu>
          <el-submenu index="2">
            <template slot="title"><i class="el-icon-caret-right"></i>内容管理</template>
            <el-menu-item-group>
              <el-menu-item index="2-1">分类管理</el-menu-item>
              <el-menu-item index="2-2">内容列表</el-menu-item>
            </el-menu-item-group>
          </el-submenu>
        </el-menu>
      </el-aside>

      <el-container>
        <el-header style="text-align: right; font-size: 12px">
          <el-dropdown>
            <i class="el-icon-setting" style="margin-right: 15px"></i>
            <el-dropdown-menu slot="dropdown">
              <el-dropdown-item>个人信息</el-dropdown-item>
              <el-dropdown-item>退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </el-dropdown>
        </el-header>
        <el-main>
          <!--在这里展示视图-->
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>
<script>
export default {
  name: "Main"
}
</script>
<style scoped>
.el-header {
  background-color: #B3C0D1;
  color: #333;
  line-height: 60px;
}
.el-aside {
  color: #333;
}
</style>
```

修改router/index.js

```
import Vue from 'vue';
import Router from "vue-router";
import Main from "../views/Main";
import Login from "../views/Login";
import UserList from '../views/user/List';
import UserProfile from '../views/user/Profile';

// 安装路由
Vue.use(Router);

// 配置导出路由
export default new Router({
  routes: [
    {
      path: '/main',
      component: Main,
      // 嵌套路由
      children: [
        {path: '/user/list', component: UserList},
        {path: '/user/profile', component: UserProfile  }
      ]
    },
    {
      path: '/login',
      component: Login,

    }
  ]
});
```

最后，`npm run dev` 查看

![image](../../../../images/posts/2021/09/vue-js/19.png)

## 参数传递与重定向

修改views/Main.vue，将个人信息的路由链接的路径修改，使用`:to`来绑定路径和参数，用一个对象来表达，例如`{name: '命名路径', parmas: {参数名: 值}}`

```
<template>
  <div>
    <el-container>
      <el-aside width="200px">
        <el-menu :default-openeds="['1']">
          <el-submenu index="1">
            <template slot="title"><i class="el-icon-caret-right"></i>用户管理</template>
            <el-menu-item-group>
              <el-menu-item index="1-1">
                <!--参数传递-->
                <router-link :to="{name: 'UserProfile', params:{id: id}}">个人信息</router-link>
              </el-menu-item>
              <el-menu-item index="1-2">
                <router-link to="/user/list">用户列表</router-link>
              </el-menu-item>
              <el-menu-item index="1-3">
                <!--重定向-->
                <router-link to="/goHome">回到主页</router-link>
              </el-menu-item>
            </el-menu-item-group>
          </el-submenu>
          <el-submenu index="2">
            <template slot="title"><i class="el-icon-caret-right"></i>内容管理</template>
            <el-menu-item-group>
              <el-menu-item index="2-1">分类管理</el-menu-item>
              <el-menu-item index="2-2">内容列表</el-menu-item>
            </el-menu-item-group>
          </el-submenu>
        </el-menu>
      </el-aside>

      <el-container>
        <el-header style="text-align: right; font-size: 12px">
          <el-dropdown>
            <i class="el-icon-setting" style="margin-right: 15px"></i>
            <el-dropdown-menu slot="dropdown">
              <el-dropdown-item>个人信息</el-dropdown-item>
              <el-dropdown-item>退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </el-dropdown>
        </el-header>
        <el-main>
          <!--在这里展示视图-->
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>
<script>
export default {
  name: "Main",
  data() {
    return {id:1}
  }
}
</script>
<style scoped>
.el-header {
  background-color: #B3C0D1;
  color: #333;
  line-height: 60px;
}
.el-aside {
  color: #333;
}
</style>
```

在此还需要修改router/index.js，给对于组件UserProfile的路由命名。允许使用props来解耦视图与数据。这里还举例重定向的例子('/goHome')

```
import Vue from 'vue';
import Router from "vue-router";
import Main from "../views/Main";
import Login from "../views/Login";
import UserList from '../views/user/List';
import UserProfile from '../views/user/Profile';

// 安装路由
Vue.use(Router);

// 配置导出路由
export default new Router({
  routes: [
    {
      path: '/main',
      component: Main,
      children: [
        {path: '/user/list', component: UserList},
        {path: '/user/profile/:id',name: 'UserProfile',component: UserProfile, props: true  }
      ]
    },
    {
      path: '/login',
      component: Login,

    },
    {
      path: '/goHome',
      redirect: '/main'
    }
  ]
});
```

修改views/UserProfile.vue，在template标签下，用一个div标签包含之前的h2，在其下面，嵌入`{{id}}`，还有组件新添属性props。

```
<template>
  <div>
    <h2>个人信息</h2>
    {{id}}
  </div>
</template>

<script>
export default {
  props: ['id'],
  name: "UserProfile"
}
</script>

<style scoped>

</style>
```

## 404和路由钩子

编写404视图组件views/NotFound.vue

```
<template>
  <div>
    404，页面丢失了
    <hr>
  </div>
</template>

<script>
export default {
  name: "NotFound"
}
</script>

<style scoped>

</style>
```

在 router/index.js 加写NotFound组件的路由。路径属性用`'*'`匹配。路由模式有两种：一是默认的hash，url带有'#'；二是history，不带'#'

```
import Vue from 'vue';
import Router from "vue-router";
import Main from "../views/Main";
import Login from "../views/Login";
import UserList from '../views/user/List';
import UserProfile from '../views/user/Profile';
import NotFound from '../views/NotFound';

// 安装路由
Vue.use(Router);

// 配置导出路由
export default new Router({
  mode: 'history',
  routes: [
    {
      path: '/main/:name',
      component: Main,
      props: true,
      children: [
        {path: '/user/list', component: UserList},
        {path: '/user/profile/:id',name: 'UserProfile',component: UserProfile, props: true  }
      ]
    },
    {
      path: '/login',
      component: Login,

    },
    {
      path: '/goHome',
      redirect: '/main'
    },
    {
      path: '*',
      component: NotFound
    }
  ]
});
```

![image](../../../../images/posts/2021/09/vue-js/20.png)


路由钩子重点看beforeRouteEnter和beforeRouteLeave

在组件Profile添加路由钩子

```
<template>
  <div>
    <h2>个人信息</h2>
    {{id}}
  </div>
</template>

<script>
export default {
  props: ['id'],
  name: "UserProfile",
  beforeRouteEnter: function(to, from, next) {
    console.log('进入路由前');
    next();
  },
  beforeRouteLeave: function(to, from, next) {
    console.log('进入路由后');
    next();
  }
}
</script>

<style scoped>

</style>
```

钩子函数默认带有三个参数 (to, from, next)。还有next方法来解析此钩子。

* next(): 进行管道中的下一个钩子。如果全部钩子执行完了，则导航的状态就是 confirmed (确认的)。

* next(false): 中断当前的导航。如果浏览器的 URL 改变了 (可能是用户手动或者浏览器后退按钮)，那么 URL 地址会重置到 from 路由对应的地址。

* next('/') 或者 next({ path: '/' }): 跳转到一个不同的地址。当前的导航被中断，然后进行一个新的导航。你可以向 next 传递任意位置对象，且允许设置诸如 replace: true、name: 'home' 之类的选项以及任何用在 router-link 的 to prop 或 router.push 中的选项。

* next(error): (2.4.0+) 如果传入 next 的参数是一个 Error 实例，则导航会被终止且该错误会被传递给 router.onError() 注册过的回调。

* next(function): 可以通过传一个回调给 next 来访问组件实例，例如 `next(vm=>{// 通过vm访问组件})`

在路由钩子中发送ajax请求

首先安装axios插件

```
sudo npm install vue-axios axios --save
```

在main.js配置导入axios

```
import Vue from 'vue';
import axios from 'axios';
import VueAxios from 'vue-axios';

Vue.use(VueAxios, axios);
```

改写beforeRouteEnter方法

```
export default {
  props: ['id'],
  name: "UserProfile",
  beforeRouteEnter: function(to, from, next) {
    console.log('进入路由前');
    next(vm=>{
      vm.getData();
    });
  },
  beforeRouteLeave: function(to, from, next) {
    console.log('进入路由后');
    next();
  },
  methods: {
    getData: function() {
      this.axios({
        method: "GET",
        url: "/static/mock/data.json"
      }).then(function(response) {
        console.log(response);
      });
    }
  }
}
```

## 更多资源

* [Vue官网](https://v3.cn.vuejs.org/guide/introduction.html)
* [Axios文档](http://axios-js.com/zh-cn/docs/index.html)
* [Vue-CLI文档](https://cli.vuejs.org/zh/)
* [Vue-Router文档](https://router.vuejs.org/zh/)
* [ElementUI文档](https://element.eleme.cn/#/zh-CN/guide/design)