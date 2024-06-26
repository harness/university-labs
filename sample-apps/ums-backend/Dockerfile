FROM bellsoft/liberica-openjre-alpine:17
WORKDIR /app/libs
COPY ./src/main/resources/opentelemetry-javaagent-1.27.0.jar /app/libs/opentelemetry-javaagent-1.27.0.jar
WORKDIR /app
COPY ./target/*.jar ./ums.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","ums.jar"]
