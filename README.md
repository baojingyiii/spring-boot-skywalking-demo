# spring-boot-skywalking-demo
> 部署skywalking,在本地编译并启动一个hello的my-spring-app,并加入探针
>
> 官方文档 https://skywalking.apache.org/docs/main/latest/en/setup/backend/backend-docker/
> 

注意：基于java8，maven 3.8.9,springboot4.0.0

## 一键部署skywalking
```bash
docker compose up -d
```
docker-compose.yml
```yaml
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

version: '3.8'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.5.0
    container_name: elasticsearch
    restart: always
    ports:
      - 9200:9200
    healthcheck:
      test: ["CMD-SHELL", "curl --silent --fail localhost:9200/_cluster/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    environment:
      - discovery.type=single-node
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ulimits:
      memlock:
        soft: -1
        hard: -1
  oap:
    image: apache/skywalking-oap-server:8.3.0-es7
    container_name: oap
    depends_on:
      - elasticsearch
    links:
      - elasticsearch
    restart: always
    ports:
      - 11800:11800
      - 12800:12800
    healthcheck:
      test: ["CMD-SHELL", "/skywalking/bin/swctl ch"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    environment:
      SW_STORAGE: elasticsearch7
      SW_STORAGE_ES_CLUSTER_NODES: elasticsearch:9200
      SW_HEALTH_CHECKER: default
      SW_TELEMETRY: prometheus
  ui:
    image: apache/skywalking-ui:8.3.0
    container_name: ui
    depends_on:
      - oap
    links:
      - oap
    restart: always
    ports:
      - 8080:8080
    environment:
      SW_OAP_ADDRESS: oap:12800
```
> 来源：https://github.com/apache/skywalking-docker/blob/master/archive/8/8.3.0/compose-es7/docker-compose.yml
>

## my-spring-app
在本机启动app,以下为示例
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
## 编译
> maven
```bash
# 1. 下载解压到用户目录
wget https://dlcdn.apache.org/maven/maven-3/3.8.9/binaries/apache-maven-3.8.9-bin.tar.gz
tar -zxvf apache-maven-3.8.9-bin.tar.gz
mv apache-maven-3.8.9 ~/maven-3.8.9

# 2. 只修改当前用户的环境变量
echo 'export PATH=~/maven-3.8.8/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 3. 验证
mvn -v
```
> java 
```bash
yum install -y java-1.8.0-openjdk-devel
```
> 编译，生成my-spring-app-1.0.0.jar
```bash 
mvn clean package -DskipTests  // target目录下会生成jar包
```
> 启动
```bash
# 测试应用是否可用：java -jar my-spring-app-1.0.0.jar    // 前台显示
nohup java -javaagent:skywalking-agent.jar -jar ../spring-boot-demo/target/my-spring-app-1.0.0.jar &    // jar包放置探针并启动
tail -f nohup.out   // 查看日志
```
注意修改agent
```bash
...
agent.service_name=${SW_AGENT_NAME:my-spring-app}  //skywalking-ui显示的应用名
...
collector.backend_service=${SW_AGENT_COLLECTOR_BACKEND_SERVICES:172.26.0.3:11800}
         // 由于skywalking为容器，而my-spring-app在本机。使用docker-compose会自动产生network
         // docker network inspect spring-boot-skywalking-demo_default:查看oap的ip
...
```
