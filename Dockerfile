# ─────────────────────────────────────────────
# Stage 1 – BUILD Native Image
# ─────────────────────────────────────────────
FROM ghcr.io/graalvm/graalvm-community:17 AS builder

WORKDIR /workspace

# Copy project files
COPY . .

# Install native-image tool
RUN gu install native-image

# Build the native image using Gradle
RUN ./gradlew nativeCompile --no-daemon

# ─────────────────────────────────────────────
# Stage 2 – RUNTIME (Alpine, no JVM needed)
# ─────────────────────────────────────────────
FROM alpine:latest

WORKDIR /app

# Copy the compiled native binary
COPY --from=builder /workspace/build/native/nativeCompile/helloworld .

# Ensure executable permissions
RUN chmod +x helloworld

# Run the native binary
ENTRYPOINT ["./helloworld"]
