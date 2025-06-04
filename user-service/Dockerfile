# SpringMon User Service Dockerfile
FROM openjdk:17-jdk-slim

# Metadata
LABEL maintainer="SpringMon Team"
LABEL version="1.0.0-SNAPSHOT"
LABEL description="SpringMon User Service - Internal User Management Service"

# Variabili d'ambiente
ENV SPRING_PROFILES_ACTIVE=docker
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

# Creazione utente non-root per sicurezza
RUN groupadd -r springmon && useradd -r -g springmon springmon

# Directory di lavoro
WORKDIR /app

# Copia il JAR dell'applicazione
COPY target/user-service-*.jar app.jar

# Cambia ownership
RUN chown -R springmon:springmon /app

# Passa all'utente non-root
USER springmon

# Porta esposta (solo per documentazione - non esposta esternamente)
EXPOSE 8083

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8083/api/health || exit 1

# Comando di avvio
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
