/*
 * Copyright (c) 2019 Spotfire AB,
 * Första Långgatan 26, SE-413 28 Göteborg, Sweden.
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Spotfire AB ("Confidential Information"). You shall not
 * disclose such Confidential Information and may not use it in any way,
 * absent an express written license agreement between you and Spotfire AB
 * or TIBCO Software Inc. that authorizes such use.
 */

-- This script creates a database and a user
--
-- as input it has these variables
--   db_name   name of the datbase
--   db_user   the user to create
--   db_pass   the password for this user

-- ===================================
--  Report errors
-- ===================================

\set ON_ERROR_STOP on

-- ===================================
--      Create Database and User
-- ===================================

create database :db_name;

create user :db_user
       with password :'db_pass'
            nocreatedb;

alter database :db_name owner to :db_user;
