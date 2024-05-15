#!/bin/sh

# Create the User Action Log database and user
export PGPASSWORD=${POSTGRES_PASSWORD}
psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f /tmp/create_actionlog_env.sql -v db_name=${ACTIONDB_NAME} -v db_user=${ACTIONDB_USER} -v db_pass=${ACTIONDB_PASSWORD}

# Create the User Action Log table
export PGPASSWORD=${ACTIONDB_PASSWORD}
psql -U ${ACTIONDB_USER} -d ${ACTIONDB_NAME} -f /tmp/create_actionlog_db.sql
