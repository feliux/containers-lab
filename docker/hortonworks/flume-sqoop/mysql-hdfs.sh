#!/bin/bash

method=export
database=m6
user=user1
password=hortonworks1
table=results
src_dir=/user/user1/results/

sqoop $method \
 --connect jdbc:mysql://localhost/$database \
 --username $user \
 --password $password \
 --fields-terminated-by '|' \
 --lines-terminated-by '\n' \
 --table $table \
 --export-dir $src_dir \
