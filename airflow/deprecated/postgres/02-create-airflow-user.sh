#!/bin/bash
set -e # Exit if a command exits with a non-zero exit code

# Create a role for airflow
echo "Creating database role: airflow"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER ${AIRFLOW_PSQL_USER} WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION PASSWORD '${AIRFLOW_PSQL_PASSWORD}';
EOSQL
