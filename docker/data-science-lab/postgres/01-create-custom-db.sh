#!/bin/bash
set -e # Exit if a command exits with a non-zero exit-code

# Create database to write general datasets into postgres
echo "Creating database"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<EOSQL
    CREATE DATABASE ${CUSTOM_DB} OWNER ${CUSTOM_USER};
    GRANT ALL PRIVILEGES ON DATABASE ${CUSTOM_DB} TO ${CUSTOM_USER};
EOSQL
