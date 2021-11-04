---
title: "HTML 语法"
date: 2021-08-23T13:22:52+08:00
description: "学习 HTML 语法，重点使用表单"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- html
categories:
- web
---

## 概述

HTML，即Hyper Text Markup Language，中文是超文本标记语言

W3C标准：
* 结构化标准(HTML,XML)
* 表现标准语言(CSS)
* 行为标准(DOM,ECMAScript) 

## HTML基本结构

例如某个web项目中的01-helloworld.html所示：

```
<!-- 01-hellworld.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>首页</title>
</head>
<body>
    
</body>
</html>
```

1. head是网页的头部，body是网页主体部分。
2. head和body元素是开放标签和闭合标签成对出现，有头有尾 ，如：`<head></head>`
3. meta元素是自闭合标签，有头无尾或有尾无头，如：`<hr />`

## 注释

单行注释

```
<!-- 单行注释 -->
```


多行注释
```
<!--
    多行注释1
    多行注释2
    ..
-->
```

## 网页基本信息

在head元素里面设置网页信息，通过meta标签设置一些元信息和title标签设置网站标题，如下：

```
<head>
    <meta charset="UTF-8">
    <meta name="keywords" content="网站搜索的关键字">
    <meta name="description" content="网站描述">
    <title>填写网站标题</title>
</head>
```

## 基本标签

网页主体的基本标签如下：

* 标题标签
* 段落标签
* 换行标签
* 水平线标签
* 字体样式标签
* 特殊符号

> 标题标签 h1~h6

```
<!-- 02-basicTag.html -->
<body>
    <h1>一级标题</h1>
    <h2>二级标题</h2>
    <h3>三级标题</h3>
    <h4>四级标题</h4>
    <h5>五级标题</h5>
    <h6>六级标题</h6>
</body>
```

> 段落标签 p

```
<body>
    <p>君不见黄河之水天上来，奔流到海不复回。</p>
    <p>君不见高堂明镜悲白发，朝如青丝暮成雪。</p>
    <p>人生得意须尽欢，莫使金樽空对月。</p>
    <p>天生我材必有用，千金散尽还复来。</p>
    <p>烹羊宰牛且为乐，会须一饮三百杯。</p>
    <p>岑夫子，丹丘生，将进酒，杯莫停。</p>
    <p>与君歌一曲，请君为我倾耳听。</p>
    <p>钟鼓馔玉不足贵，但愿长醉不复醒。</p>
    <p>古来圣贤皆寂寞，惟有饮者留其名。</p>
    <p>陈王昔时宴平乐，斗酒十千恣欢谑。</p>
    <p>主人何为言少钱，径须沽取对君酌。</p>
    <p>五花马、千金裘，呼儿将出换美酒，与尔同销万古愁。</p>
</body>

```

> 换行标签 br

```
<body>
    君不见黄河之水天上来，奔流到海不复回。<br/>
    君不见高堂明镜悲白发，朝如青丝暮成雪。<br/>
    人生得意须尽欢，莫使金樽空对月。<br/>
    天生我材必有用，千金散尽还复来。<br/>
    烹羊宰牛且为乐，会须一饮三百杯。<br/>
    岑夫子，丹丘生，将进酒，杯莫停。<br/>
    与君歌一曲，请君为我倾耳听。<br/>
    钟鼓馔玉不足贵，但愿长醉不复醒。<br/>
    古来圣贤皆寂寞，惟有饮者留其名。<br/>
    陈王昔时宴平乐，斗酒十千恣欢谑。<br/>
    主人何为言少钱，径须沽取对君酌。<br/>
    五花马、千金裘，呼儿将出换美酒，与尔同销万古愁。<br/>
</body>
```

> 水平线标签

```
<body>
    <hr/>
</body>
```

> 字体样式标签 strong,em,del

```
<body>
    粗体：<strong>hahaha</strong><br/>
    斜体：<em>hahaha</em><br/>
    删除线：<del>hahaha</del><br/>
</body>
```

> 特殊符号

```
<body>
    空&nbsp;&nbsp;&nbsp;格<br/>
    小于号&lt; 小于等于&le;<br/>
    大于号&gt; 大于等于&ge;<br/>
    等于&Equal; 不等于&NotEqual;<br/>
    版权符号&copy;<br/>
</body>
```

## 图像标签

常见图片格式：

* JPG
* GIF
* PNG
* BMP

```
<img src="path" alter="text" title="word" width="x" height="y">
```

1. src\* 图片位置（绝对路径/相对路径）
2. alter\* 替换文本
3. title 悬停文字
4. width 图片宽度
5. height 图片高度

\* 表示必填

```
<!-- 03-imgTag.html -->
<body>
    <!-- resouces/image存在1.png，没有2.png -->
    <img src="../resouces/image/1.png" alt="凯瑟琳" title="凯瑟琳" width="500px" height="300px"><br/>
    <img src="../resouces/image/2.png" alt="凯瑟琳" title="凯瑟琳" width="500px" height="300px">
</body>
```

## 超链接

* 文本链接
* 图片链接

```
<a href="url" target="window">
    可以是文本，也可以是图片
</a>
```

1. href\* 超文本引用，超链接地址
2. target 目标窗口，如：新标签页跳转_blank/默认当前标签页跳转_self/_parent/_top/自定义(iframe的name)

```
<!-- 04-aTag.html -->
<body>
    <!-- 描链接 -->
    <a name="top">顶部</a>
    <!-- 文本链接 -->
    <a href="01-helloworld.html" >跳转到..</a>
    <a href="https://www.baidu.com" >去百度</a>
    <!-- 邮件链接 -->
    <a href="mailto:lixiaoqin28@outlook.com">联系邮箱</a><br/>
    <!-- 图片链接 -->

    <a href="01-helloworld.html" >
        <img src="../resouces/image/1.png" alt="凯瑟琳" title="凯瑟琳" width="500px" height="300px"><br/>
    </a>
    <img src="../resouces/image/1.png" alt="凯瑟琳" title="凯瑟琳" width="500px" height="300px"><br/>
    <img src="../resouces/image/1.png" alt="凯瑟琳" title="凯瑟琳" width="500px" height="300px"><br/>
    <img src="../resouces/image/1.png" alt="凯瑟琳" title="凯瑟琳" width="500px" height="300px"><br/>
    <img src="../resouces/image/1.png" alt="凯瑟琳" title="凯瑟琳" width="500px" height="300px"><br/>

    <!-- 描链接 -->
    <a href="#top">回到顶部</a>
</body>
```

## 行内元素和块元素

* 快元素 独占一行 如：p、h1~h6、div ...
* 行内元素 内容撑开，左右皆是行内元素可以排在一行 如：a、strong、em、del、span、input ...

## 列表标签

* 有序列表 ol>li
* 无序列表 ul>li
* 自定义列表 dl>dt+dd

```
<!-- 05-listTag.html -->
<body>
    <!-- 
        有序列表 
        试卷、问答 ...
    -->
    <ol>
        <li>Java</li>
        <li>Linux</li>
        <li>Web</li>
        <li>C/C++</li>
    </ol>
    
    <!-- 
        无序列表
        导航栏，测表栏
     -->
    <ul>
        <li>Java</li>
        <li>Linux</li>
        <li>Web</li>
        <li>C/C++</li>

    </ul>


    <!-- 
        自定义列表 
        dl 标签
        dt 列表名称
        dd 列表内容
        网站底部
    -->
    <dl>
        <dt>subject</dt>
        <dd>Java</dd>
        <dd>Linux</dd>
        <dd>Web</dd>
        <dd>C/C++</dd>
    </dl>
    
</body>
```

## 表格标签

```
<!-- 06-tableTag.html -->
<body>
    <!-- 表格标签 -->
    <table border="1px">
        <tr>
            <!-- colspan 跨列 -->
            <td colspan="3" >学生成绩 </td>
        </tr>
        <tr>
            <!-- rowspan 跨行 -->
            <td rowspan="2">小红</td>
            <td>语文</td>
            <td>100</td>
        </tr>
        <tr>
            <td>数学</td>
            <td>100</td>
        </tr>
        <tr>
            <!-- rowspan 跨行 -->
            <td rowspan="2">小明</td>
            <td>语文</td>
            <td>100</td>
        </tr>
        <tr>
            <td>数学</td>
            <td>100</td>
        </tr>
    </table>
</body>
```

## 媒体元素

* 音频元素
* 视频元素

```
<!-- 07-mediaTag.html -->
<body>
    <!-- 视频标签 -->
    <video src="../resouces/video/1.mp4" controls autoplay width="1511px" height="750px"></video>
    <!-- 音频标签 -->
    <audio src="../resouces/audio/1.mp3" controls autoplay></audio>   
</body>
```

## 页面结构

* header* 标记头部区域内容
* footer* 标记脚部区域内容
* section 一块独立区域
* article 独立的文章内容
* aside 相关内容或应用，常见于侧边栏
* nav* 导航辅助内容

\* 重点

```
<!-- 08-pageStructure.html -->
<body>
    <header>
        <h2>页面内容头部</h2>
    </header>
    <section>
        <h2>页面内容主体</h2>
    </section>
    <footer>
        <h2>页面内容脚部</h2>
    </footer>
</body>
```

## 内联框架

```
<iframe src="path" name="mainFrame" width="x" height="y"> </iframe>
```

* src 嵌入的HTML地址
* name 框架的名称
* width 框架的宽度
* height 框架的高度

可以和a标签搭配使用

```
<!-- 09-iframeTag.html -->
<body>
    <iframe src="#" 
        name="frame" scrolling="no" border="0" frameborder="no" framespacing="0" allowfullscreen="true" width="750px" height="405px"> 
    </iframe>
    <a href="https://player.bilibili.com/player.html?aid=929767931&bvid=BV13K4y1S75r&cid=315710506&page=1" target="frame">点击</a>
</body>
```

## 表单

最简单的表单：
```
<!-- 10-formTag.html -->
<body>
    <form method="post" action="#" enctype="application/x-www-form-urlencoded">
        用户名：<input type="text" name="uname"><br/>
        密码：<input type="password" name="pwd"><br/>
        <input type="submit" value="提交">
        <input type="reset" value="重置">
    </form>
</body>
```

* method 提交方式 post/get
* action 表单提交的位置，可以是网站，也可以是请求地址
* enctype 表单内容类型 如：multipart/form-data（文件上传必选）、application/x-www-form-urlencoded（默认）

> 文本框

```
<p>用户名：<input type="text" name="uname" value="admin" maxLength="8" size="30"></p>
```
* type 文本框 text
* name 提交表单时，数据项的名称
* value 数据项的默认初始值
* maxLength 最大可输入字符数
* size 文本框宽度

> 单选框

```
<p>性别：
    <input type="radio" name="gender" value="male" checked /> 男
    <input type="radio" name="gender" value="female" /> 女
</p>
```

* type 单选框 radio
* value 选项的值，不能改变
* checked 有则默认选中，无不选中

> 多选框

```
<p>爱好：
    <input type="checkbox" name="hobby" value="movie" /> 电影
    <input type="checkbox" name="hobby" value="song" /> 歌曲
    <input type="checkbox" name="hobby" value="game" /> 游戏
</p>
```

* type  多选框 checkbox
* checked 有则默认选中，无不选中

> 列表框
```
 <p>所在地
    <select name="location">
        <option value="Guangdong" selected>广东</option>
        <option value="Shanghai">上海</option>
        <option value="Beijing">北京</option>
    </select>
</p>
```

* selected 有默认选中，无不选中

> 文本域

```
<p>个人简介:
    <textarea name="introduction" cols="80" rows="10">我是...</textarea>
</p>
```

* cols 文本域的初始列数
* rows 文本域初始行数

> 按钮

```
<p>
    <input type="image"  src="../resources/image/2.png" width="30px" height="30px"/>
</p>
<p>
    <input type="button" name="btn1" value="按钮" />
    <input type="submit" value="提交">
    <input type="reset" value="重置">
</p>
```

> 文件域

常用于文件上传

```
<p>上传：
    <input type="file" name="files" />
</p>
```

> 其他

```
<p>邮箱
    <input type="email" name="email" />
</p>
<p>电话：
    <input type="tel" name="tel" />
</p>
<p>url：
    <input type="url" name="url" />
</p>
<p>搜索：
    <input type="search" name="search" />
</p>
<p>数量：
    <input type="number" name="number" min="0" max="100" step="10" />
</p>
<p>范围：
    <input type="range" name="range" min="0" max="100" step="2"/>
</p>
```

* min type为number/range 的最小值
* max type为number/range 的最大值
* step type为number/range 步长值

### label与input

```
<label for="uname">用户名</label>
<input type="text" name="uname" id="uname" />
```

鼠标点击label，聚焦for对应指定的id值（这里是uname）的元素。

### 常见输入框的属性

表单输入框的属性

* reaonly 表示只读不可修改
* disabled 禁用输入框
* hidden 隐藏输入框

```
<p>用户名：<input type="text" name="admin" readonly></p>

<p>性别：
    <input type="radio" name="gender" value="male" checked  disabled/> 男
    <input type="radio" name="gender" value="female" /> 女
</p>

<p>密码：<input type="password" name="pwd" hidden></p>
```

### 表单验证

表单输入框的属性用于简单的验证输入

* placeholder 输入框提示
* required 输入框必须有输入，防止空输入
* pattern 对输入框内容进行模式匹配验证

```
<p>用户名：<input type="text" name="admin" placeholder="请输入用户名"></p>
<p>密码：<input type="password" name="pwd" required></p>
<p>邮箱
    <input type="email" name="email" pattern="\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" />
</p>
```

## 其他资源

* [w3cschool](https://www.w3school.com.cn/)
* [菜鸟教程](https://www.runoob.com/)