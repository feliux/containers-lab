#!/bin/sh

# Create the table spaces and user
export PGPASSWORD=${POSTGRES_PASSWORD}
psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f /tmp/create_server_env.sql -v db_name=${SERVERDB_NAME} -v db_user=${SERVERDB_USER} -v db_pass=${SERVERDB_PASSWORD}

# Create the tables and fill them with initial data
export PGPASSWORD=${SERVERDB_PASSWORD}
psql -U ${SERVERDB_USER} -d ${SERVERDB_NAME} -f /tmp/create_server_db.sql

psql -U ${SERVERDB_USER} -d ${SERVERDB_NAME} -f /tmp/populate_server_db.sql
