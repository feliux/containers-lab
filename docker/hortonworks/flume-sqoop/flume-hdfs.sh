#!/bin/bash

conf=/usr/hdp/current/flume-server/conf/
conf_file=/home/user1/flume-hdfs.conf
agent=m6

flume-ng agent --conf $conf --conf-file $conf_file --name $agent
