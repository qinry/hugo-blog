---
title: "Git 分支"
date: 2021-08-18T17:44:40+08:00
description: "Git分支相关操作：创建、切换、合并、删除等等"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
categories:
- git
---

## 创建分支

`git branch <分支名>`

```
git branch dev
```


## 查看分支

```
git branch # 等价于git branch -a，显示所有分支
```

效果：
![picture](../../../../images/posts/2021/08/git-branch/1.png)

\* 表示当前活跃的分支

## 切换分支

`git checkout <分支名>`

```
git checkout dev
```

效果：

![picture](../../../../images/posts/2021/08/git-branch/2.png)


创建并切换到新分支
```
git checkout -b feature
```

效果：

![picture](../../../../images/posts/2021/08/git-branch/3.png)

## 合并分支

### 合并前的准备

假如在master分支，新建了sample.txt并提交，提交信息维 "init commit"

sample.txt内容如下：

```
创建sample.txt
```

用git log查看提交信息
![picture](../../../../images/posts/2021/08/git-branch/4.png)

### 模拟两个分支的并行操作

切换到feature分支，在 sample.txt 追加新内容，并提交

![picture](../../../../images/posts/2021/08/git-branch/5.png)

![picture](../../../../images/posts/2021/08/git-branch/6.png)


切换到dev分支，也在 sample.txt 也追加新内容

![picture](../../../../images/posts/2021/08/git-branch/7.png)


### merge合并分支

切换回master分支，合并dev的提交到master。

```
git checkout master
git merge dev
```

效果：
![picture](../../../../images/posts/2021/08/git-branch/8.png)

此分支间若没有冲突，会自动处理合并，由于dev包含了master的记录，通过把master分支的位置移动到dev的最新分支，则会快进合并（fast-forward）

### 解决合并时的冲突

```
git merge feature
```
效果：
![picture](../../../../images/posts/2021/08/git-branch/9.png)

提示master和feature冲突发生在sample.txt

查看 sample.txt

![picture](../../../../images/posts/2021/08/git-branch/10.png)

"<<<<<<<<<"和"==========="之间表示当前分支的提交

"========="和">>>>>>>>>>>"之间表示合并分支引入的提交

处理冲突后，效果：
![picture](../../../../images/posts/2021/08/git-branch/11.png)



### rebase合并分支

```
git reset --hard HEAD~
git checkout feature
git rebase master
```

效果：
![picture](../../../../images/posts/2021/08/git-branch/12.png)

与使用merge合并分支时一样，处理冲突后

```
git add sample.txt
git rebase --continue
git checkout master
git merge feature
```

效果：

![picture](../../../../images/posts/2021/08/git-branch/13.png)


### 删除分支

`git branch -d <要删除分支名>`

```
git branch issue
git branch -d issue
```