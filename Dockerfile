# Stage 1: Build the application
FROM maven:3.8.4-jdk-11-slim AS build
WORKDIR /app
COPY . .
RUN mvn clean package

# Stage 2: Run the application
FROM adoptopenjdk/openjdk11:alpine-jre
WORKDIR /opt/app
COPY --from=build /app/target/spring-boot-web.jar app.jar
ENTRYPOINT ["java","-jar","app.jar"]
