---
title: "简简单单知道递归"
date: 2020-04-27T20:21:23+08:00
description: "简简单单知道递归"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- 递归
categories:
- 算法
---

## 一、递归的含义

递归就是函数或方法通过调用自己本身来达到解决问题的目的，这种解法形式叫递归。用欧几里得算法的 Java 描述说明问题：

任意一对非负整数 p，q（p > q），设 r 是 p 与 q 相除的余数。p，q 的最大公约数等于 q，r 的最大公约数。

```java
public static int gcd(int p, int q) {
    if(q == 0) return p;
    int r = p % q;
    return gcd(q, r);
}
```

## 二、为什么使用递归

* 面对某些复杂的问题使用递归可以很好的描述并有效解决，例如汉诺塔问题、二叉树的遍历、查询目录等等。

* 递归使算法实现的代码更加简洁，而且可能更加易懂。

{{< notice info "误区——迭代一定比递归的效率高" >}}
当递归使用的是尾递归本质其是就是迭代，效率不亚于普通迭代(不考虑函数的开销，递归比迭代更好)。如果使用使用双递归、三递归等等，才会是算法极度低效的反例
{{< /notice >}}


## 三、如何使用递归

使用数学归纳法诠释重要三点：

1. 递归总有一个最简单的情况：方法的第一句总是包含`return`的条件语句

2. 递归调用总是尝试解决一个规模更小的子问题，递归才能收敛到最简单的情况。

3. 递归调用的父问题和尝试解决的子问题之间不应该有交集。

## 四、一些递归的例子

### 4.1 阶乘

```java
public static int fact(int N) {
        if(N == 0) return 1;
        return N * fact(N - 1);
}
```

典型的尾递归，效率最高的递归形式

### 4.2 斐波那契数列

```java
public static int fibonacci(int N) {
        if(N == 0) return 0;
        if(N == 1) return 1;
        return fibonacci(N - 2) + fibonacci(N - 1);
}
```

典型的双递归，子问题有重复了工作，问题有交集，故效率低于迭代形式
迭代如下：

```java
public static int fibonacci(int N) {
    int n_2 = 0, n_1 = 1;
    int temp;
    for(int i = 0; i < N; i++) {
        temp = n_2 + n_1;
        n_2 = n_1;
        n_1 = temp;
    }
    return n_2;
}
```

### 4.3 幂运算

底数，指数为非负整数的幂运算
```java
public static int pow(int X, int N) {
    if(N == 0) return 1;
    if(N == 1) return X;
    if(N % 2 == 0)
        return pow(X*X, N/2);
    else
        return pow(X*X, N/2) * X;

}
```

根据条件分路解决规模更小子问题，递归调用次数随N递减不呈指数增长,而是线性增长,也是尾递归。

## 参考

* 维基百科-辗转相除法(https://zh.wikipedia.org/wiki/%E8%BC%BE%E8%BD%89%E7%9B%B8%E9%99%A4%E6%B3%95#%E6%AD%A3%E7%A1%AE%E6%80%A7%E7%9A%84%E8%AF%81%E6%98%8E)
