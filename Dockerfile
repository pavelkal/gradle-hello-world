# Stage 1: build fat JAR
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app
COPY . .
RUN chmod +x ./gradlew
RUN ./gradlew clean shadowJar -x test

# Stage 2: runtime קטן, non-root
FROM eclipse-temurin:17-jre-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=builder /app/build/libs/*-all.jar app.jar
USER appuser
ENTRYPOINT ["java", "-jar", "app.jar"]
