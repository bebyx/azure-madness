# Build stage
FROM gradle:8.1-jdk17 AS builder
WORKDIR /workspace
COPY . .
RUN gradle clean bootJar

# Run image
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=builder /workspace/build/libs/hello-world-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
