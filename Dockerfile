FROM maven:3.8.4-jdk-11-slim AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src/ /app/src/
RUN mvn package -DskipTests

FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/spring-boot-app.jar /app/spring-boot-app.jar
ENTRYPOINT ["java", "-jar", "spring-boot-app.jar"]
