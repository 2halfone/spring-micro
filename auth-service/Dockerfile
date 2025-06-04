# SpringMon Auth Service Dockerfile
FROM openjdk:17-jdk-slim

# Metadata
LABEL maintainer="SpringMon Team"
LABEL version="1.0.0-SNAPSHOT"
LABEL description="SpringMon Auth Service - Internal Authentication Service"

# Variabili d'ambiente
ENV SPRING_PROFILES_ACTIVE=docker
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

# Creazione utente non-root per sicurezza
RUN groupadd -r springmon && useradd -r -g springmon springmon

# Directory di lavoro
WORKDIR /app

# Copia il JAR dell'applicazione
COPY target/auth-service-*.jar app.jar

# Cambio proprietario dei file
RUN chown -R springmon:springmon /app

# Cambio utente
USER springmon

# Espone la porta 8081 (SOLO NETWORK INTERNO)
EXPOSE 8081

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8081/actuator/health || exit 1

# Comando di avvio
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
