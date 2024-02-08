# Build stage
FROM maven:3.8.4-jdk-11-slim AS build
WORKDIR /app
COPY . .
RUN mvn install

# Final stage
FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/spring-boot-web.jar /app/app.jar
EXPOSE 8081  # Expose port 8081 for the application
ENTRYPOINT ["java", "-jar", "app.jar"]
