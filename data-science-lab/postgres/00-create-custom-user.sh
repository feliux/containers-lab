#!/bin/bash
set -e # Exit if a command exits with a non-zero exit-code


# Create a custom role to read & write general datasets into postgres
echo "Creating database role: custom user"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER ${CUSTOM_USER} WITH LOGIN NOSUPERUSER CREATEDB NOCREATEROLE NOINHERIT NOREPLICATION PASSWORD '${CUSTOM_PASSWORD}';
EOSQL
