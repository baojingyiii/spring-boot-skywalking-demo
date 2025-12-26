FROM apache/skywalking-java-agent:8.5.0-jdk8  
COPY spring-boot-demo/target/*.jar /app/boot.jar
ENV SW_AGENT_NAME=my-spring-app
ENV SW_AGENT_COLLECTOR_BACKEND_SERVICES=oap:11800
ENV SW_AGENT_PROTOCOL=v3
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/boot.jar"]



