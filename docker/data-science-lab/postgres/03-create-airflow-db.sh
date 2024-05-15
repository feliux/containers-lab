#!/bin/bash
set -e # Exit if a command exits with a non-zero exit-code

# Create database for airflow
echo "Creating database: airflow"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<EOSQL
    CREATE DATABASE ${AIRFLOW_PSQL_DB} OWNER ${AIRFLOW_PSQL_USER};
    GRANT ALL PRIVILEGES ON DATABASE ${AIRFLOW_PSQL_DB} TO ${AIRFLOW_PSQL_USER};
EOSQL
