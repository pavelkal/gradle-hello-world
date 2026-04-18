# ─────────────────────────────────────────────
# Stage 1 – BUILD
# Uses the official Gradle + JDK 17 image to compile
# and package the fat JAR with the Shadow plugin.
# ─────────────────────────────────────────────
FROM gradle:7.6-jdk17 AS builder

WORKDIR /workspace

# Copy only dependency-related files first so Docker can cache
# the dependency-download layer separately from the source layer.
COPY build.gradle.kts gradle.properties ./
COPY gradle ./gradle

# Download dependencies (cached unless build files change)
RUN gradle dependencies --no-daemon 

# Now copy the actual source and build
COPY src ./src
RUN gradle shadowJar --no-daemon


# ─────────────────────────────────────────────
# Stage 2 – RUNTIME
# Minimal JRE image – no build tools, smaller attack surface.
# ─────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine

# Create a dedicated non-root user and group (task requirement)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Pull the fat JAR from the build stage
COPY --from=builder /workspace/build/libs/gradle-hello-world-*.jar app.jar

# Drop root privileges
USER appuser

ENTRYPOINT ["java", "-jar", "app.jar"]