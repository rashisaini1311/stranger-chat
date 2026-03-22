# syntax=docker/dockerfile:1

# Build stage: compile the Spring Boot jar using Maven + Java 21.
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

COPY pom.xml ./
COPY .mvn .mvn
COPY mvnw mvnw
COPY mvnw.cmd mvnw.cmd
RUN chmod +x mvnw
RUN ./mvnw -q -DskipTests dependency:go-offline

COPY src src
RUN ./mvnw -q clean package -DskipTests

# Runtime stage: lightweight Java 21 image with only the app jar.
FROM eclipse-temurin:21-jre
WORKDIR /app

COPY --from=build /app/target/stranger-chat-0.0.1-SNAPSHOT.jar app.jar

# Render provides PORT at runtime. Keep a sensible default for local docker runs.
ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]

