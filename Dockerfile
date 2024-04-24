# Use a builder stage to set up Keycloak and handle configurations
FROM quay.io/keycloak/keycloak:latest as builder

WORKDIR /opt/keycloak
RUN /opt/keycloak/bin/kc.sh build

# Final stage to create the actual image
FROM quay.io/keycloak/keycloak:latest

# Copy the built Keycloak from the builder stage
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Set environment variables for database and server configuration
ENV KC_DB=mssql
ENV KC_DB_URL="jdbc:sqlserver://sql-algo-identity.database.windows.net:1433;database=sqldb-algo-identity-production"
ENV KC_DB_USERNAME="algo-identity-admin"
ENV KC_DB_PASSWORD="5edcac80-e0ed-4324-b196-aa4018fa2957"
#ENV KC_KEYCLOAK_USER=admin
#ENV KC_KEYCLOAK_PASSWORD=admin
ENV KC_HOSTNAME=localhost

# New environment variables for HTTP configuration
ENV KC_HTTP_ENABLED=true
ENV KC_HTTP_PORT=8080
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME_STRICT_HTTPS=false

EXPOSE 8080

# Use kc.sh to start Keycloak in development mode with specified DB and transaction settings
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--db=mssql", "--transaction-xa-enabled=false"]
