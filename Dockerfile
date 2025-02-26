# ---- Step 1: Build Stage ----
FROM eclipse-temurin:17-jdk AS builder

# Set working directory
WORKDIR /app

# Copy Gradle wrapper and dependency files (to leverage caching)
COPY gradle gradle
COPY gradlew .
COPY build.gradle .
COPY settings.gradle .
RUN chmod +x gradlew

# Download dependencies (will be cached if no changes)
RUN ./gradlew dependencies --no-daemon

# Copy the project files
COPY . .

# Build the Spring Boot app
RUN ./gradlew bootJar --no-daemon

# ---- Step 2: Runtime Stage ----
FROM eclipse-temurin:17-jre AS runtime

# Set working directory
WORKDIR /app

# Create non-root user
RUN useradd -m springuser

# Copy built JAR from the builder stage
COPY --from=builder /app/build/libs/*.jar app.jar

# Set permissions
RUN chown -R springuser:springuser /app
USER springuser

# Expose application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]