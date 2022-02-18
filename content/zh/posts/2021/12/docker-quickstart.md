---
title: "Docker 快速开始"
date: 2021-12-07T10:55:26+08:00
description: "Docker 快速开始"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- docker
categories:
- docker
---

## Docker 概述

Docker 是一个用于开发、传送和运行应用程序的开放平台。使应用和基础设施隔离。像管理应用一样管理设施。

Docker 容器：打包和运行应用的隔离环境。

Docker提供的服务：

* 开发应用的支持性组件可以在容器中运行
* 容器可当作发布和测试单元
* 当要部署应用时，可以为应用编排服务部署到生产环境的容器中。

## Docker 架构

<img src="../../../../images/posts/2021/12/docker-quickstart/1.png">

使用客户端-服务端的架构。客户端与服务端可在同一系统，也可以客户端连接远程服务端（Docker Host）。客户端发送命令，服务端接受命令后操作，比如构建、运行和发布等。

还一种客户端是 Docker Compose ，使用它让一组容器来组成的应用程序，就是所谓的服务编排。

* Docker Daemon - 监听 Docker API 请求和管理 Docker 对象 如：镜像images，容器containers，网络networks，数据卷volumes
* Docker Client - 与 Docker 交互的主要工具，当运行 `docker run` 时，客户端把命令发送 给 `dockerd` 并执行
* Docker registries - 存储 Docker 镜像。Docker Hub 是官方镜像站点。使用 `docker pull` 从仓库获取镜像。`docker push` 来上传镜像
* Docker objects
    * images - 用于创建容器说明的只读模版。`docker images` 可查看已拉取的镜像

    * containers - 正在运行的镜像实例。docker ps可查看运行中的容器
* Docker Desktop - 包含了 Docker Daemon、Docker Client 和 Docker Compose等组件 在 Windows 和 Mac 下运行的桌面应用

## Docker 安装

在 Linux 上的安装。Linux 的发行版是 CentOS 7。

```bash
# 更新包
yum update
# 安装依赖
yum install -y yum-utils device-mapper-persistent-data lvm2
# 设置 docker 的 yum 源
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# 安装
yum install -y docker-ce
# 完成后，检查
docker -v
```

最终显示：
```
Docker version 20.10.11, build dea9396
```

## 常用命令

### docker daemon 管理

```bash
# 启动 docker daemon
systemctl start docker
# 关闭
systemctl stop docker
# 重启
systemctl restart docker
# 查看进程信息
systemctl status docker
# 允许开机自启
systemctl enable docker
```

### 镜像管理
```bash
# 查看本地所有镜像
docker images
# 查看所有镜像id
docker images -q
# 从仓库搜索镜像，这里 mysql 指 镜像名称
docker search mysql
# 拉取/下载镜像，可以指定镜像 mysql 版本
docker pull mysql:5.7
# 使用 CONTAINER ID(容器ID) 删除镜像，具体ID具体查看
docker rmi 59b80c0eb775
# 删除所有
docker rmi `docker images -q`
```

### 容器管理

```bash
# 查看运行的容器
docker ps
# 查看所有容器，包括运行的和运行退出的
docker ps -a
```

```bash
# 创建并运行容器
docker run -id \
-p 3306:3306  \
--name mysql \
-v ~/docker-data/mysql/data:/data \
-e MYSQL_ROOT_PASSWORD=root \
mysql:5.7


# 连接容器, /bin/bash 是进入容器使用的命令
docker exec -it mysql /bin/bash
docker exec -it mysql mysql -uroot -p
```

* -i - 保持容器运行。容器创建后，运行，再退出，不会删除容器。它可与d和t连用
* -d - 后台运行容器
* -t - 分配一个伪终端
* –name - 为容器命名
* -p - 端口映射，容器与宿主机隔离的，要想从宿主机访问容器，需要做端口映射，前者是宿主端口，后者才是容器端口。使用数据卷也是先宿主后容器。
* -v - 使用数据卷，宿主机的目录与容器目录绑定。用于数据交互和持久化。如果宿主机目录未指定，就使用默认生成的目录。
* -e - 定义容器使用的环境变量。这里指定 MySQL root 用户密码。
* –volumes-from - 继承其他容器的数据卷。

```bash
# 停止容器
docker stop mysql
# 启动容器
docker start mysql
# 删除容器
docker rm mysql
# 查看容器信息
docker inspect mysql
```
> 数据卷就是宿主机下的目录或文件，可以被多个容器挂载。容器可以挂载多个数据卷


## Docker 镜像原理

Docker镜像本质是一个分层的文件系统。

它基于 Linux 文件系统，Linux包括了bootfs和rootfs。最底层bootfs包含引导加载程序和内核，但镜像的bootfs使用的是宿主机的。这就是镜像文件比Linux某些发行版如 CentOS 的 ISO 镜像 的尺寸还有小的原因。

往上层的rootfs就是 Linux 的 root 文件系统，称作基础镜像。然后再往上叠加其他镜像。使用统一文件系统技术把多层文件系统虚拟化成一个文件系统。

一个子镜像还可以放在一个父镜像上面，如 Tomcat 镜像依赖于父镜像 OpenJDK 和基础镜像。

当镜像启动容器时，会在最顶层加载一个可读写的文件系统作为容器。

## 镜像制作

### 将现有容器制作成镜像

```bash
# 容器49842ef82091 转镜像 mytomcat:1.0
docker commit 49842ef82091 mytomcat:1.0
# 压缩镜像
docker save -o mytomcat.tar mytomcat:1.0
# 从压缩文件导入镜像
docker load -i mytomcat.tar
```

### 用Dockerfile制作镜像

Dockerfile 是文本文件，包含构建镜像说明。当执行 `docker build` 会读取这个文件的指令来帮助构建镜像。Dockerfile的默认文件名就是"Dockerfile"。
如果不使用默认名，则可命名为 `Dockerfile.<something>/ <something>.Dockerfile`，命令执行时用 –file（-f）指定它。项目的主Dockerfile建议使用默认的。

按照官方的教程的构建第一个Java 应用镜像如下

由于是在Linux下使用docker，运行 `docker build` 设置环境变量来启用 BuildKit，例如：

```bash
DOCKER_BUILDKIT=1 docker build .
```

可以配置文件来默认启用

```json:/etc/docker/daemon.json
{
  "features":{"buildkit" : true}
}

```
然后重启 docker

从github克隆一个demo

```bash
cd ~
git clone https://github.com/spring-projects/spring-petclinic.git
cd spring-petclinic
```

可以去测试一下这个demo是否能正常运行
```bash
./mvnw spring-boot:run
```

用浏览器打开 http://localhost:8080，如果使用虚拟机 Linux 并从宿主机访问,localhost 要改成虚拟机的ip即可。

接着创建一个Dockerfile

```Dockerfile
# syntax=docker/dockerfile:1

FROM openjdk:16-alpine3.13

WORKDIR /app

COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline

COPY src ./src

CMD ["./mvnw", "spring-boot:run"]
```

第1行：告诉 docker 构建器所使用dockerfile的版本1语法。

第3行：使用openjdk的镜像，它包含 Java JDK ，就能够运行 Java 程序

第5行：设置镜像的工作目录。后续指令将在这个目录下进行。方便我们后续使用相对路径而非绝对路径

第7、8行：为了后续执行 `./mvnw dependency` 命令，需要将 Maven Wrapper 和 pom.xml文件放入镜像内。COPY指令有两个参数，第一个是要复制的文件，可以多个文件，第二个是复制到的目标。第7行目标是文件，第8行的目标是目录。注：最后空格后的肯定是第二个参数。

第9行：RUN 像在shell运行命令，这里会下载maven项目的依赖项到镜像

第11行：将源代码复制到镜像

第13行：CMD 指定当制作的镜像在容器内执行时，将会执行的操作。

RUN是构建时执行的命令，而CMD运行时执行的命令。

它由一些列命令构成。每个指令基于基础镜像构成一层文件系统，最终形成镜像。

[其他更多的Dockerfile指令见](https://docs.docker.com/engine/reference/builder/)

再接着，创建 .dockeringnore 文件让 docker 构建时要忽略的文件或目录，以提高构建性能。这里 maven 测试这个 demo 会生成一个输出目录 target，可以忽略掉。

.dockerignore的内容如下：

```
target
```

最后构建镜像
```bash
docker build --tag java-docker .
```

* `--tag` - 给镜像打标签 格式是 “名号:版本标签”，如：java-docker:v1.0.0。如果没指定标签，默认使用 latest
* `.` - 命令最后的 . 是构建镜像的上下文。它是指定了路径所在文件集合，这里表示当前路径下的文件集。构建过程将会处理这些文件

可以通过 docker images 查看所制作的镜像。还可以创建新的标签如： `docker tag java-docker:latest docker:v1.0.0`

Dockerfile 的优点：

* 保证开发人员可以为团队提供完全一致的开发环境
* 保证测试人员可以直接使用开发人员的构建的镜像或使用Dockerfile构建新镜像进行测试
* 为运维人员，部署应用时无须担心环境迁移的问题。可以无缝移植。

###  运行制作好的镜像为容器

```bash
docker run -dp 8080:8080 --name springboot-server java-docker
curl --request GET \
--url http://localhost:8080/actuator/health \
--header 'content-type: application/json'
```
输出：
```
{"status":"UP"}
```

在开发应用时，可能需要其他容器作为支持，比如 Spring Boot 应用容器需要 MySQL 数据库容器支持

首先在容器中创建 MySQL 数据库，使用数据卷让多个容器共享数据和配置

```bash
docker volume create mysql_data
docker volume create mysql_config
```
创建 network 让应用和数据库共享此网络以互相通信。这里的 network 为用户定义的桥接网络。为了在后面的定义 jdbc url 的时候可以作为用服务名当作连接字符串来使用。
如：jdbc:mysql://mysqlserver/petclinic

```bash
docker network create mysqlnet
```

运行mysql容器

```bash
docker run -it --rm -d -v mysql_data:/var/lib/mysql \
-v mysql_config:/etc/mysql/conf.d \
--network mysqlnet \
--name mysqlserver \
-e MYSQL_USER=petclinic -e MYSQL_PASSWORD=petclinic \
-e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=petclinic \
-p 3306:3306 mysql
```

上一节中的 springboot-server 容器想要使用 MySQL ，就要修改 Dockerfile 文件，将 CMD 的修改为：

```
CMD ["./mvnw", "spring-boot:run", "-Dspring-boot.run.profiles=mysql", "-Dmaven.test.skip"]
```

使这个 demo 从 H2 内存数据库切换为 MySQL 数据库，重新新构建一次。然后启动容器连接 mysqlserver。

```bash
docker run --rm -d \
--name springboot-server \
--network mysqlnet \
-e MYSQL_URL=jdbc:mysql://mysqlserver/petclinic \
-p 8080:8080 java-docker
```

## Docker Compose 借助容器开发应用

编写第一个compose文件
```txt:docker-compose.dev.yml
version: '3.8'
services:
  petclinic:
    build:
      context: .
    ports:
      - 8000:8000
      - 8080:8080
    environment:
      - SERVER_PORT=8080
      - MYSQL_URL=jdbc:mysql://mysqlserver/petclinic
    volumes:
      - ./:/app
    command: ./mvnw spring-boot:run -Dmaven.test.skip -Dspring-boot.run.profiles=mysql -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000"

  mysqlserver:
    image: mysql:latest
    ports:
      - 3306:3306
    environment:
      - MYSQL_ROOT_PASSWORD=
      - MYSQL_ALLOW_EMPTY_PASSWORD=true
      - MYSQL_USER=petclinic
      - MYSQL_PASSWORD=petclinic
      - MYSQL_DATABASE=petclinic
    volumes:
      - mysql_data:/var/lib/mysql
      - mysql_config:/etc/mysql/conf.d
volumes:
  mysql_data:
  mysql_config:
```
启动应用前安装 docker compose
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
接着编译镜像并运行
```bash
docker-compose -f docker-compose.dev.yml up --build
```

Dockerfile和docker-compose.yml区别

前者是制作自定义镜像的说明，后者是容器集群做快速编排，用于部署分布式应用。

