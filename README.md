# spring-boot-skywalking-demo 
> [![Docker](https://img.shields.io/badge/Docker-✔-2496ED.svg)](https://www.docker.com/)
>
> 官方文档 https://skywalking.apache.org/docs/main/latest/en/setup/backend/backend-docker/

完整的Spring Boot应用集成SkyWalking APM监控解决方案：在本机启动spring boot应用，skywalking追踪监控（skywalking容器）
> 
> ![Elasticsearch](https://img.shields.io/badge/Elasticsearch-7.5.0-brightgreen)
> 
> [![SkyWalking](https://img.shields.io/badge/SkyWalking-8.3.0-orange)](https://skywalking.apache.org/)
>
> ![java 1.8.0](https://img.shields.io/static/v1?label=java&message=1.8.0&color=blue)
>
> ![maven 3.8.9](https://img.shields.io/static/v1?label=maven&message=3.8.9&color=blue)
>
> [![spring-boot 2.7.0](https://img.shields.io/static/v1?label=spring-boot&message=2.7.0&color=blue)](https://spring.io/)

## 📋 项目简介

这是一个完整的Spring Boot应用监控示例，使用Apache SkyWalking进行应用性能管理和链路追踪。

### ✨ 特性
- 🚀 一键部署完整的SkyWalking监控环境
- 🔍 Spring Boot应用无缝集成SkyWalking探针
- 📊 可视化的应用性能监控和链路追踪
- 🐳 基于Docker Compose的容器化部署
- 📈 支持Elasticsearch作为存储后端

## 🏗️ 技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| Java | 1.8.0 | 运行环境 |
| Spring Boot | 2.7.0 | Web应用框架 |
| SkyWalking | 8.3.0 | APM监控系统 |
| Elasticsearch | 7.5.0 | 数据存储 |
| Docker | Latest | 容器化部署 |

## 🚀 快速开始

### 前置要求
- Docker 20.10+
- Docker Compose 2.0+
- Java 1.8+
- Maven 3.8+

### 1. 克隆项目
```bash
git clone https://github.com/baojingyiii/spring-boot-skywalking-demo.git
cd spring-boot-skywalking-demo
```

### 2. 部署SkyWalking监控系统
```bash
# 一键启动所有服务
docker compose up -d

# 查看服务状态
docker compose ps

# 访问SkyWalking UI
# 地址: http://localhost:8080
```

### 示例应用接口

项目包含一个简单的测试接口：
```java
package com.baojingyi.prom.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    @GetMapping("/hello")
    public String Hello(){
        return "hello";

    }

}
```

```bash 
java -jar my-spring-app-1.0.0.jar    // 前台显示（测试应用是否可用）
```
访问测试：`http://localhost:8888/hello`
![my-spring-app](./docs/images/my-spring-app.png)

### 3. 编译Spring Boot应用
> 编译，生成my-spring-app-1.0.0.jar
> 
```bash 
mvn clean package -DskipTests  // target目录下会生成jar包
```

### 4. 启动应用并集成SkyWalking探针
```bash
nohup java -javaagent:skywalking-agent.jar -jar ../spring-boot-demo/target/my-spring-app-1.0.0.jar &    // jar包放置探针并启动
```
> ❗下载指定版本的SkyWalking agent:`wget https://archive.apache.org/dist/skywalking/8.3.0/apache-skywalking-apm-8.3.0.tar.gz `
## 📊 监控效果

### SkyWalking UI 界面
![skywalking-ui](./docs/images/skywalking-ui.png)
### 应用拓扑图
![skywalking-拓扑图](./docs/images/skywalking-拓扑图.png)

## 📁 项目结构
```
spring-boot-skywalking-demo/
├── spring-boot-demo/          # Spring Boot应用源码
│   ├── src/
│   ├── pom.xml
│   └── target/
├── agent/                     # SkyWalking Agent配置
│   ├── skywalking-agent.jar
│   └── config/
│       └── agent.config      # Agent配置文件
├── docker-compose.yml        # SkyWalking容器编排
├── dockerfile               # 应用Docker镜像
└── docs/                    # 文档和截图
    └── images/
        ├── skywalking-ui.png
        └── skywalking-topology.png
```

## 🔧 配置说明
### SkyWalking Agent配置

修改 `agent/config/agent.config`：

```properties
# 服务名称（在SkyWalking UI中显示）
agent.service_name=my-spring-app

# OAP服务器地址
# 注意：如果应用运行在宿主机，需要使用容器IP
collector.backend_service=172.26.0.3:11800 

# 获取容器IP的方法：
# docker network inspect spring-boot-skywalking-demo_default
```
## 🔍 故障排查

### 常见问题

1. **端口冲突**

   ```bash
   # 检查端口占用
   netstat -ntpl

   # 停止冲突进程
   kill -9 <PID>
   ```

2. **网络连接问题**

   ```bash
   # 测试OAP连接
   telnet 172.26.0.3 11800

   # 检查容器网络
   docker network inspect spring-boot-skywalking-demo_default
   ```

3. **应用无法启动**
   
   ```bash
   # 查看详细日志
   tail -f nohup.out

   # 检查Java版本
   java -version
   ```

### 服务状态检查
```bash
# 检查所有服务
docker compose ps

# 查看日志
docker compose logs -f

# 检查SkyWalking UI
curl -I http://localhost:8080
```

## 🧪 测试与验证

### 1. 验证应用运行

```bash
# 测试应用接口
curl http://localhost:8888/hello

# 预期输出: "hello"
```

### 2. 验证SkyWalking监控

1. 访问 `http://localhost:8080`
2. 在服务列表中找到 `my-spring-app`
3. 点击进入查看监控数据
4. 测试接口触发链路追踪

### 3. 性能测试

```bash
# 使用ab进行简单压力测试
yum install httpd-tools
ab -n 100 -c 10 http://localhost:8888/hello

# 观察SkyWalking中的响应时间和QPS
[root@master spring-boot-demo]# ab -n 100 -c 10 http://localhost:8888/hello
Server Software:
Server Hostname:        localhost
Server Port:            8888

Document Path:          /hello
Document Length:        5 bytes

Concurrency Level:      10
Time taken for tests:   0.545 seconds
Complete requests:      100
Failed requests:        0
Write errors:           0
Total transferred:      13700 bytes
HTML transferred:       500 bytes
Requests per second:    183.62 [#/sec] (mean)
Time per request:       54.461 [ms] (mean)
Time per request:       5.446 [ms] (mean, across all concurrent requests)
Transfer rate:          24.57 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    4   4.2      2      22
Processing:     8   44  27.1     38     126
Waiting:        1   34  21.5     31     101
Total:         12   48  26.6     40     127
```

## 📚 学习资源

- [SkyWalking官方文档](https://skywalking.apache.org/docs/main/latest/en/setup/backend/backend-docker/)
- [Spring Boot文档](https://spring.io/projects/spring-boot)
- [Docker Compose文档](https://docs.docker.com/compose/)
- [APM概念介绍](https://skywalking.apache.org/docs/main/latest/en/concepts-and-designs/overview/)

## 👥 作者

**baojingyiii**

- GitHub: [@baojingyiii](https://github.com/baojingyiii)

## 🙏 致谢

- [Apache SkyWalking](https://skywalking.apache.org/)
- [Spring Boot](https://spring.io/projects/spring-boot)
- [Elasticsearch](https://www.elastic.co/)
- [Docker](https://www.docker.com/)
