---
title: "Javascript 语法"
date: 2021-08-21T10:08:07+08:00
description: "学习JavaScript 语法和 jQuery"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- javascript
categories:
- web
---

## 概述

**Javascript** 一种Web的编程语言，是互联网最流行的脚本语言。可以插入到HTML中，被所有的浏览器所执行。
ECMAScript 6，简称 ES6。ECMAScript 可以理解是 Javascript 的标准化规范。


## 使用方式

引入外部文件，js代码可以写在后缀为js文件


```
// main.js
// javascript 代码写在这个文件
// ...
```


```
<!-- index.html -->
<!DOCTYPE html>
<html>
    <head>
        <script src="main.js"></script>
    </head>
    <body>
    </body>
</html>
```

嵌入到HTML内部使用

```
<!DOCTYPE html>
<html>
    <head>
        <script>
            // javascript代码写在这里
            // ...
        </script>
    </head>
    <body>
    </body>
</html>
```

js命名严格区分大小写

## 简述数据类型

js的数据类型有数值、文本、图形、音频、视频等等

变量定义格式
```
var 全局变量 = 值;
let 局部变量 = 值;
```

变量名不能以数字开头，可以以字母、下划线_和美元符号$开头

注意：
* null 表示空，是一种表示空的数据类型
* undefined 表示未定义，说明变量未声明或声明但未初始化，依然为未定义


### 严格检查模式
```
'user strict'; // 严格检查模式，必须写在第一行
```

### 数字

不区分小数和整数，例如：

```
123 // 整数
123.1 // 浮点数
1.234e3 // 科学计数法
-99 // 负数
NaN // Not a Number
Infinity // 无穷大
```

### 字符串

用单引号或双引号表示，例如：
```
"abc"
'abc'
```

### 布尔

有两个值true或false

### 数组

使用中括号[]表示。这里数组，每个元素可以不相同，但建议保持使用一样的数据类型

例如：
```
var ia = [ 1,2,3,4 ];
var sa = [ "hello", "world" ];
var ba = [ true, false ];
var matrix = [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ];
```

### 对象

使用大括号{}表示，对象的属性以 `属性名:值` 格式表示，属性之间用逗号隔开，最后的属性不加逗号

```
var person = {
    name: "zhangsan",
    age: 13
}
var personName = person.name
var personAge = person.age
```

### null

表示一个变量为空
```
var a = null;
```


## 运算符

### 逻辑运算符

```
&& 短路与
|| 短路或
! 否
```

### 比较运算符

```
!= 不等于
== 等于，表示值相等返回true
=== 绝对等于，表示类型相等，值也相等，返回true
> 大于
>= 大于等于
< 小于
<= 小于等于
```

建议使用 === ，而不是 ==

注意：

* NaN === NaN，NaN和任何数或NaN比较相等返回false

* isNaN方法，判断变量是否为NaN

### 其他



## 进一步了解数据类型

### 字符串

1、转义字符

```
\\ 反斜杠
\' 单引号
\" 双引号
\n 换行符
\t 制表符
\u4e2d unicode字符 \u0000~\uffff 十六进制
\x41 ascii字符 \x00~\x7f 十六进制
```

2、多行字符串

```
var str = `hello
world`;
```

3、模式字符串

```
var world = "world!";
var str = `hello, ${world}`; // 结果："hello, world!"
```

4、字符串长度

```
var str = "hello, javascript";
var len = str.length;
```

5、字符串可变性与否

字符串可通过下标取出包含的字符，如：`str[0]`。字符串不可变，即使 `str[0] = 'b';` ，也不能改变 str里面的值。

6、大小写转换

```
var str = "student";
str.toUpperCase();
str.toLowerCase();
```

7、子字符串

```
var str = "student";
var sub = str.substring(0, 3);
```

8、索引

```
var str = "student";
var idx = str.indexOf('t');
```

### 数组

1、长度

```
var arr = [ 1, 2, 3, 4, 5 ];
var len = arr.length;
```

长度可变，数组大小也会改变。如果长度变小，数组元素会丢失；如果长度变大，数组后面填充empty，其实是undefined。

2、索引

```
var arr = [ 1, 2, 3, 4, 5 ];
var idx = arr.indexOf(2);
```

3、分片

```
var arr = [ 1, 2, 3, 4, 5 ];
var subarr = arr.slice(1, 4); // 取下标1到5（不包含）的子数组
```

4、添加和移除尾部元素

```
var arr = [ 1, 2, 3, 4, 5 ];
arr.push(6, 7); // 函数参数是可变参数，添加一或多个元素到尾部
var lastValue = arr.pop(); // 移除元素
```

5、添加和移除首部元素

```
var arr = [ 1, 2, 3, 4, 5 ];
arr.unshift(-2, 0); // 函数参数是可变参数，添加一或多个元素到首部
var firstValue = arr.shift(); // 移除元素
```

6、排序

```
var arr = [ 3, 1, 5, 4, 2 ]
arr.sort();
```

7、元素反转

```
var arr = [ 1, 2, 3, 4, 5 ];
arr.reverse();
```

8、合并

不改变原数组，返回合并后的数组

```
var arr = [ 1, 2, 3, 4, 5 ];
arr.concat([ 6, 7, 8] );
```

9、连接

将数组元素连接成字符串，参数为连接符，默认为","

```
var arr = [ 1, 2, 3, 4, 5 ];
var str = arr.join("-"); // 结果：1-2-3-4-5
```

10、多维数组

取值
```
var matrix = [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ];
var value = matrix[1][1];
```

### 对象

以对象person为例：

```
var person = {
    name: "张三",
    age: 18,
    email: "zhangsan@163.com",
    score: 0
};
```

1、设置属性
```
person.name = "李四";
person.gender = "男"; // 设置不存在属性，对象增添该属性
```

2、获得属性值

```
var personName = person.name;
var gender = person.gender; // 不存在属性，返回undefined，没有报错
```

3、删除属性

```
var flag = delete person.gender; // 删除该属性，若属性存在，返回true，否则返回undefined
```

4、判断对象包含的属性

可以是`"属性名" in 对象名` 来判断，也可以是`对象名.hasOwnProperty(属性名)`。

```
var exists = "age" in person; // 存在返回true，否则返回false
exists = person.hasOwnProperty("name"); // 与上行类似
```

他们区别，in还可以判断某个方法是否在这个对象，hasOwnProperty方法显然不行。
例如：
```
"toString" in person; // 结果：true
person.hasOwnProperty("toString"); // 结果： false
```

## 流程控制

### if分支

```
var score = 88;
if (score < 0 || score > 100) {
    alert("分数在不合理范围");
}
if (score >= 90) {
    console.log("优秀");
} else if (score >= 80) {
    console.log("良好");
} else if (score >= 70) {
    console.log("中等");
} else if (score >= 60) {
    console.log("及格");
} else {
    console.log("不及格");
}
```

console.log(...) 在浏览器控制台输出消息。alert(...) 浏览器弹窗显示消息

### while循环

```
var i = 0;
while (i < 5) {
    console.log(i);
    i++;
}

do {
    i--;
    console.log(i);
} while(i > 0);
```

### for循环

```
for (let i = 0; i < 5; i++) {
    console.log(i);
}
```

### foreach循环

```
var arr = [ 1, 2, 3, 4, 5 ];
// 不建议使用 for .. in 遍历数组，如果arr新增属性，也会被遍历出来，有漏洞
for (let idx in arr) {
    console.log(arr[idx]);
}

for (let val of arr) {
    console.log(val);
}

var person = {
    name: "张三",
    age: 18,
    email: "zhangsan@163.com",
    score: 0
};

for (let key in person) {
    console.log(person[key]);
}
```

## 集合

### map

> map增删改查
```
var map = new Map([ ["jack", 90],["rocco", 88] ]); // 新建Map 可传参：二维数组 表示键值对
map.set("tom", 100); // 增
map.delete("tom"); // 删：成功返回true，否则返回false
map.set("rocco", 100); // 改
map.get("jack"); // 查
```

> 遍历map

```
for (let x of map) {
    console.log(x[0] + " => " + x[1]);
}
```

### set

> set增删查
```
var set = new Set([1,2,3,3]);
set.add(4); // 增
set.delete(3); // 删
set.has(2); // 查
```

> 遍历set
```
for (let x of set) {
    console.log(x);
}
```

## 函数

### 定义函数

> 方式1
```
function methodName(paramName) {
    //...
    return returnVal;
}

function abs(x) {
    if (typeof x !== "number") {
        throw "arg x not a number";
    }
    return x >= 0 ? x : -x;
}
var val = abs(-2);
```

> 方式2

```
var methodName = function(paramName) {
    //...
    return returnVal;
}

var abs = function(x) {
    if (typeof x !== "Number") {
        throw "arg x not a number";
    }
    return x >= 0 ? x : -x;
}
var val = abs(-2);
```

通过 typeof 得到变量的类型，进行类型判断。throw + 异常信息 就可以抛出异常


### arguments关键字

arguments包含函数的所有参数，其实是数组
```
function log(str) {
    if (typeof str !== "String") {
        throw "arg str not a String";
    }
    if (arguments.length == 1) {
        console.log(str);
    } else if (arguments.length > 1) {
        console.log(str);
        for (let i = 1; i < arguments.length; i++) {
            console.log(arguments[i]);
        }
    }
    
}
log("hello", "world", "!");
```

### 可变参数

```
function log(str, ...rest) {
    if (typeof str !== "String") {
        throw "arg str not a String";
    }
    console.log(str);
    for (let msg of rest) {
        console.log(msg);
    }
}
log("hello", "world", "!");
```

### 作用域

在函数内部声明的局部变量，只能在其函数内部使用。

```
function f1() {
    var x = 1;
    function f2() {
        x++;
        console.log(x);
    }
    return f2;
}
var f = f1();
f();
```

这里函数f2是个闭包，f2内部能访问到f1中的变量x，并能自增1。f1返回值为f2。那么函数外部可以通过f1的返回值访问到f1内部的局部变量。

在函数外声明的全局变量，能被所有函数访问。全部的全局变量会绑定为全局对象window的属性。

```
var global_x = 1;
function f1() {
    console.log(global_x);
}
console.log(window.global_x);
```

函数查找变量，从其内部往外查找，直到全局作用域，内部覆盖外部同名变量。

注意：

* 建议函数内部所有声明的变量的位置都放在函数体的头部。不该在需要某一变量的地方声明。
* 建议所有的全局变量，放到同一个对象中，这个对象绑定为window属性，这个属性里面再放入许多的全局变量，来减少命名冲突。比如：jQuery 这个库的全局变量放到了名为"jQuery"的对象中，其还有一个别名：$。

### let关键字

解决局部作用冲突问题。建议函数局部变量使用let声明

```
for (var i = 0; i < 5; i++) {
    console.log(i);
}
console.log(i+1);

for (let i = 0; i < 5; i++) {
    console.log(i+1);
}
// console.log(i+1);// ! let声明的i不会在for循环外生效，而var会
```

### const关键字

定义常量，使用关键字const

```
const PI = "3.1415";
// PI = "123"; // ! 常量PI只读，不能修改
```

### 方法

对象包含的变量为属性，对象包含的函数为方法

> 方式1

```
var person = {
    name: "zhangsan",
    birth: 1999,
    age: function() {
        var now = new Date().getFullYear();
        return now - this.birth;
    }
}
person.age();
```

方法使用对象的属性，要用 this.属性名 获取。

> 方式2

```
function getAge() {
    var now = new Date().getFullYear();
    return now - this.birth;
}

var person = {
    name: "zhangsan",
    birth: 1999,
    age: getAge
}
person.age();
```

### apply

控制函数中this的指向

```
function getAge() {
    var now = new Date().getFullYear();
    return now - this.birth;
}

var person = {
    name: "zhangsan",
    birth: 1999,
    age: getAge
}
getAge.apply(person, []);
```

## 内部对象

### 标准对象

```
typeof 123;
"number"
typeof "123";
"string"
typeof true;
"boolean"
typeof NaN;
"number"
typeof [];
"object"
typeof {};
"object"
```

### Date

> 常用方法

```
var now = new Date();
now.getFullYear();
now.getMonth(); // 0-11
now.getDate(); 
now.getDay(); // 星期几
now.getHours();
now.getMinutes();
now.getSeconds();
now.getTime(); // 时间戳
now = new Date(1629555024108);
```

> 日期转文本

```
var     now = new Date(1629555024108);
now.toLocaleString();
```

### JSON

对象转JSON字符串
```
var person = {
    name: "张三",
    age: 18,
    email: "zhangsan@163.com",
    score: 0
};
var jsonPerson = JSON.stringify(person);
console.log(jsonPerson);
```

JSON字符串转对象
```
var person = JSON.parse('{"name":"张三","age":18,"email":"zhangsan@163.com","score":0}');
console.log(person.name)
```

## 面向对象

> 原型对象

```
function Student(name) {
    this.name = name;
}

Student.prototype.hello = function(){
    alert('hello');
};



// 继承
function Pupil(name, age) {
    Student.call(this,name);
    this.age = age; 
}

Pupil.prototype.showAge = function() {
    alert('age:'+this.age);
}
var pu = new Pupil('lisi', 8);
var stu = new Student("zhangsan");
pu.showAge();
stu.hello();
```

> class对象

```
class Student {
    constructor(name) {
        this.name = name;
    }
    hello() {
        alert('hello');
    }
}
// 继承
class Pupil extends Student {
    constructor(name, age) {
        super(name);
        this.age = age;
    }
    showAge() {
        alert("age:"+this.age);
    }
}
var p = new Pupil('lisi', 8);
var s = new Student('zhangsan');
p.showAge();
s.hello();
```

## 操作BOM对象

BOM，即 Browser Object Model，中文是浏览器对象模型

几个常见浏览器内核：

* IE
* Chrome
* FireFox
* Safari

> window

代表浏览器的窗口

```
window.alert('..')
window.innerHeight
window.innerWidth
window.outerHeight
window.outerWidth
```

> navigator

封装浏览器信息

```
navigator.appName
navigator.appVersion
navigator.platform
navigator.userAgent
```

navigator信息会被人为修改，所以不建议使用这些属性，来编写代码

> screen

表示屏幕信息

```
screen.height
screen.width
```

> location

代表定位

```
location.host
location.protocol // https
location.href
location.hostname
location.reload() // 刷新
location.assign('..') // 重定向
```

> history
表示历史记录

```
history.back()
history.forward()
```

不建议使用，可以是ajax完成页面的局部刷新来替代。

> document

表示当前页面，就是HTML 文档树

```
document.title
document.getElementById('..'); // id选择文档树结点
document.cookie // cookie不安全，服务端需要设置cookie httpOnly属性，那么document.cookie无法访问设置该属性的cookie
```

## 操作DOM对象

DOM，即 Document Object Model，中文为文档对象模型。

浏览器页面本质就是DOM树结构

核心操作：
* 更新节点
* 遍历节点
* 删除节点
* 新增节点

假如有这么一个html文件：

```
<html>
    <head>
        <meta charset="utf-8">
        <title>操作DOM对象</title>
        <style type="text/css">
            .p2 {
                color: red;
                font-size: 100px;   
            }
        </style>
    </head>
    <body>
        <div id="father">
            <h1>一级标题</h1>
            <p id="p1">p1</p>
            <p class="p2">p2</p>
        </div>
        <script>
            // ... 操作DOM节点
        </script>
    </body>
</html>
```

### 查找节点

```
// 根据选择器选择元素节点
var h1 = document.getElementsByTagName('h1').item(0);
var p1 = document.getElementById('p1');
var p2 = document.getElementsByClassName('p2').item(0);
var father = document.getElementById('father');

// 获取所有子元素节点
var children = father.children;
// 第一个子元素节点
var first = father.firstElementChild
// 最后一个子元素节点
var last= father.lastElementChild;

// 下一个相邻元素节点
var next = first.nextElementSibling;
// 上一个相邻元素节点
var prev = last.previousElementSibling;

```

### 更新节点

```
h1.innerText = 'h1'; // 修改文本内容
h1.innerHTML = '<strong>h1</strong>'; // 修改超文本内容，可以解析HTML
// 修改元素的css
h1.style.color = 'red';
h1.style.fontSize = '20px';
h1.style.padding = '2em';
```

### 删除节点

步骤：首先查找删除节点的父节点，再通过父节点删除

```
father.removeChild(p1);

var father2 =  p1.parentElement; // 获取父元素节点
father2.removechild(p2);
```

### 新增节点

新增方法传入的是已有的元素节点，则是元素节点

> append
在父节点内部追加一个子节点到尾部


```
var p3 = document.createElement('p');
p3.setAttribute('id', 'p3');
// p3.id = 'p3'; // 与上行等效
p3.innerText = 'p3';
father.append(p3); 
```

> insertBefore
在父节点内部的目标子节点前插入一个节点

```
var p3 = document.createElement('p');
p3.setAttribute('id', 'p3');
p3.innerText = 'p3';
father.insertBefore(p3, p2); // father内部的目标p2前插入p3
```

> prepend
在父节点内部追加一个子节点到头部部

```
var p3 = document.createElement('p');
p3.setAttribute('id', 'p3');
p3.innerText = 'p3';
father.prepend(p3);
```

> before
在目标节点前面插入新节点

```
var p3 = document.createElement('p');
p3.setAttribute('id', 'p3');
p3.innerText = 'p3';
p2.before(p3);
```

> after

在目标节点后面插入新节点

```
var p3 = document.createElement('p');
p3.setAttribute('id', 'p3');
p3.innerText = 'p3';
p2.after(p3);
```

## 验证表单

> 登录或注册表单的验证
假如有这样一个html文件

```
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title>验证表单</title>
        <script src="https://cdn.bootcdn.net/ajax/libs/blueimp-md5/2.18.0/js/md5.min.js"></script>
    </head>
    <body>
        <div>
            <form action="#" method="post" onsubmit="return checkForm()">
                <label>用户名:</label>
                <input type="text" id="uname" name="uname"> <br>
                <label>密码:</label>
                <input type="password" id="input-pwd"> <br>
                <input type="hidden" id="md5-pwd" name="pwd"> <br>
                <button type="submit" >提交</button>
            </form>
        </div>
        <script>
            function checkForm() {
                var uname = document.getElementById('uname').value;
                var pwd = document.getElementById('input-pwd').value;
                var md5_pwd_elem = document.getElementById('md5-pwd');
                md5_pwd_elem.value = md5(pwd);
                return true;
            }
        </script>
    </body>
</html>
```

1. 引入bootcdn的md5.min.js文件，用它使用md5算法加密密码文本
2. form的属性 onsubmit 用来表单在提交时绑定的事件，这里是checkForm函数，目的是用来验证表单
3. id为input-pwd的密码输入框用于接受密码的输入，id为md5-pwd的隐藏域用来真正提交的加密过的密码
4. 提交表单上传的数据，对应的文本必须有name属性，用来标示对应的数据项
5. 选择的input元素elem可以使用value属性获取表单输入的值，或设置他们的value的值来改变输入的值。但是输入是固定选项的话，则使用checked或selected属性的真与否来判断所选择的值是哪一个。

> 获取单选框、多选框、下拉框所选定的值

```
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title>验证表单</title>
    </head>
    <body>
        <div>
            <form action="#" method="post" onsubmit="return checkForm()">
                <label>性别</label>
                <input type="radio" name="gender" value="male"> 男
                <input type="radio" name="gender" value="female"> 女 <br>
                <label>爱好</label>
                <input type="checkbox" name="hobby" value="movie"> 电影
                <input type="checkbox" name="hobby" value="song"> 听歌
                <input type="checkbox" name="hobby" value="game"> 游戏 <br>
                <label>选择编程语言</label>
                <select name="language" id="language">
                    <option value="C">C</option>
                    <option value="Java">Java</option>
                    <option value="JavaScript">JavaScript</option>
                </select><br>
                <button type="submit">提交</button>
            </form>
        </div>
        <script>
           // .. javascript代码位置
           function checkForm() {
               // ..
               return true;
           }
        </script>
    </body>
</html>
```

判断选项框是否选中

```
document.getElementById('boy').checked; // 结果： true/false
document.getElementById('girl').checked;

var hobby = document.getElementsByName('hobby');
hobby[0].checked; // 结果：true / false
hobby[1].checked;
hobby[2].checked;

var lang = document.getElementById('language');
var idx = lang.selectedIndex; // 结果： 0 ~ lang.length - 1
lang[idx].selected; // 结果： true / false
```

## jQuery

**jQuery** 是 javascript 的封装库，旨在减少书写javascript的代码量，能够做更多的事情。更多详情在官网在[那里](https://jquery.com/)


### 导入jQuery的方式

方式1：CDN导入

CDN选择很多，这里是使用BootCDN的jQuery。

```
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.6.0/jquery.js"></script>
    </head>
    <body>
        <div>
        
        </div>
        <script>
           // .. javascript代码位置
        
        </script>
    </body>
</html>
```

方式2：本地导入

需要到官网[下载](https://jquery.com/download/)未压缩的开发用的jQuery，再本地导入到web项目中。

```
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <script src="./jquery-3.6.0.js"></script>

    </head>
    <body>
        <div>
        
        </div>
        <script>
           // .. javascript代码位置
        
        </script>
    </body>
</html>
```

### jQuery公式

使用jQuery通常来查找DOM节点，它有一个通用的公式：

```
$(selector).action(function(){

});
```

selector指的是选择器，利用CSS选择器的语法来查找DOM节点，action指节点绑定或监听的事件。事件大致分为鼠标事件、键盘事件和其他事件。

### jQuery选择器

基本选择器

* #id：根据给定的ID匹配一个元素。
* element：根据给定的元素标签名匹配所有元素。
* .class：根据给定的css类名匹配元素。
* \*：匹配所有元素。
* selector1,selector2,selectorN：将每一个选择器匹配到的元素合并后一起返回。可以指定任意多个选择器，并将匹配到的元素合并到一个结果内。

层级选择器

* ancestor descendant：在给定的祖先元素下匹配所有的后代元素
* parent > child：在给定的父元素下匹配所有的子元素
* prev + next：匹配所有紧接在 prev 元素后的 next 元素
* prev ~ sliblings：匹配 prev 元素之后的所有 siblings 元素


基本筛选器

"selector:filter" 代表在selector基础上使用filter筛选元素

filter有如下：

* :first ：获取第一个元素
* :last：获取最后个元素
* :not(selector)：去除所有与给定选择器匹配的元素
* :even：匹配所有索引值为偶数的元素，从 0 开始计数
* :odd：匹配所有索引值为奇数的元素，从 0 开始计数
* :eq(index)：匹配一个给定索引值的元素
* :gt(index)：匹配所有大于给定索引值的元素
* :lt(index)：匹配所有小于给定索引值的元素
* :header：匹配如 h1, h2, h3之类的标题元素

内容筛选

* :contains(text)：匹配包含给定文本的元素
* :empty：匹配所有不包含子元素或者文本的空元素
* :has(selector)：匹配含有选择器所匹配的元素的元素
* :parent：匹配含有子元素或者文本的元素

可见性筛选

* :hidden：匹配所有不可见元素，或者type为hidden的元素
* :visible：匹配所有的可见元素


子元素筛选

* :first-child：匹配所给选择器( :之前的选择器)的第一个子元素
* :last-child：匹配最后一个子元素
* :nth-child(n|even|odd)：匹配其父元素下的第N个子或奇偶元素
* :nth-last-child(n|even|odd|formula)：选择所有他们父元素的第n个子元素。计数从最后一个元素开始到第一个。
* :first-of-type：结构化伪类，匹配E的父元素的第一个E类型的孩子。
* :last-of-type：结构化伪类，匹配E的父元素的最后一个E类型的孩子
* :nth-of-type(n|even|odd|formula)：选择同属于一个父元素之下，并且标签名相同的子元素中的第n个。
* :nth-last-of-type(n|even|odd|formula)：选择同属于一个父元素之下，并且标签名相同的子元素中的第n个，计数从最后一个元素到第一个。


属性筛选

* [attribute]：匹配包含给定属性的元素。
* [attribute=value]：匹配给定的属性是某个特定值的元素
* [attribute!=value]：匹配所有不含有指定的属性，或者属性不等于特定值的元素。
* [attribute^=value]：匹配给定的属性是以某些值开头的元素
* [attribute$=value]：匹配给定的属性是以某些值结尾的元素
* [attribute*=value]：匹配给定的属性是以包含某些值的元素

表单

* :input：匹配所有 input, textarea, select 和 button 元素
* :text：匹配所有的单行文本框
* :password：匹配所有密码框
* :radio：匹配所有单选按钮
* :checkbox：匹配所有复选框
* :submit：匹配所有提交按钮，理论上只匹配 type="submit" 的input或者button，但是现在的很多浏览器，button元素默认的type即为submit，所以很多情况下，不设置type的button也会成为筛选结果
* :image：匹配所有图像域
* :reset：匹配所有重置按钮
* :button：匹配所有按钮
* :file：匹配所有文件域

表单对象属性

* :enabled：匹配所有可用元素
* :disabled：匹配所有不可用元素
* :checked：匹配所有选中的radio或checkbox等元素
* :selected：匹配所有选中的option元素

### 绑定事件

鼠标事件

* mousedown([[data],fn])：当鼠标指针移动到元素上方，并按下鼠标按键时，会发生 mousedown 事件。
* mouseup([[data],fn])：当在元素上放松鼠标按钮时，会发生 mouseup 事件。
* mouseenter([[data],fn])：当鼠标指针穿过元素时，会发生 mouseenter 事件。
* mouseleave([[data],fn])：当鼠标指针离开元素时，会发生 mouseleave 事件。
* mousemove([[data],fn])：当鼠标指针在指定的元素中移动时，就会发生 mousemove 事件。
* mouseover([[data],fn])：与 mouseenter 事件不同，不论鼠标指针穿过被选元素或其子元素，都会触发 mouseover 事件。
* mouseout([[data],fn])：与 mouseleave 事件不同，不论鼠标指针离开被选元素还是任何子元素，都会触发 mouseout 事件。
* scroll([[data],fn])：当用户滚动指定的元素时，会发生 scroll 事件。

键盘事件

* keydown([[data],fn])：当键盘或按钮被按下时，发生 keydown 事件。
* keypress([[data],fn])：与 keydown 事件不同，每插入一个字符，就会发生 keypress 事件。
* keyup([[data],fn])：当按钮被松开时，发生 keyup 事件。它发生在当前获得焦点的元素上。

其它事件

* blur([[data],fn])：当元素失去焦点时触发 blur 事件。
* change([[data],fn])：当元素的值发生改变时，会发生 change 事件。仅适用于文本域（text field），以及 textarea 和 select 元素。
* click([[data],fn])：点击元素，触发click事件。
* dbclick([[data],fn])：双击元素，触发click事件。
* focus([[data],fn])：当元素获得焦点时，触发 focus 事件。
* focusin([[data],fn])：当元素获得焦点时，触发 focusin 事件。focusin事件跟focus事件区别在于，他可以在父元素上检测子元素获取焦点的情况。
* focusout([[data],fn])：当元素失去焦点时触发 focusout 事件。focusout事件跟blur事件区别在于，他可以在父元素上检测子元素失去焦点的情况。
* resize([[data],fn])：当调整浏览器窗口的大小时，发生 resize 事件。
* submit([[data],fn])：当提交表单时，会发生 submit 事件。
* select([[data],fn])：当 textarea 或文本类型的 input 元素中的文本被选择时，会发生 select 事件。
* ready(fn)：当DOM载入就绪可以查询及操纵时绑定一个要执行的函数。


样例：
```
<script>
    $(function(){ // 文档就绪时触发的事件
        $(':input').blur();
    });
</script>
```

### jQuery操作DOM

更新DOM
```
$(selector).html(); // 获取超文本内容
$(selector).html('..'); // 设置超文本内容
$(selector).text(); // 获取文本内容
$(selector).text('..'); // 设置文本内容
```

CSS操作
```
$(selector).css({key:value});
```

元素的显示与隐藏
```
$(selector).hide(); // 隐藏元素
$(selector).show(); // 显示元素
```

window的宽高
```
$(window).height();
$(window).width();
```

### ajax异步请求

```
$.ajax({
    type: 'GET', /* GET/POST 请求方式 */
    url: 'url', /* 请求地址 */
    data: {key:value}, /* 传入的数据 */
    dataType: "JSON", /* 接受的数据格式 */
    async: true, /* true/false 是否异步 */
    success: function(data) { // 请求成功后的响应事件

    },
    error: function() { // 请求失败后的响应事件

    }
});
```

## 其他资源

* [jQuery API 中文文档](https://jquery.cuishifeng.cn/)