# Build stage
FROM maven as build
WORKDIR /app
COPY . .
RUN mvn install

# Final stage
FROM openjdk:11.0.10-jre
WORKDIR /app
COPY --from=build /app/target/spring-boot-web.jar /app/spring-boot-web.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/spring-boot-web.jar"]
