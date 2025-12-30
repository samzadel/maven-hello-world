FROM maven:3.9-eclipse-temurin-17-alpine AS builder
WORKDIR /app
# Copy only pom.xml to cache dependencies
COPY myapp/pom.xml .
# Download dependencies (cached if pom.xml doesn't change)
RUN mvn dependency:go-offline
# Copy source code
COPY myapp/src ./src
# Compile, run tests and create JAR
RUN mvn clean package

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN adduser -D appuser
USER appuser
COPY --from=builder /app/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]