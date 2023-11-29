#!/bin/bash

# Set Java home
export JAVA_HOME=/usr/local/openjdk-11

# Start Hadoop services
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh


# Set environment variable for Ambari home
export AMBARI_HOME=/usr/local/ambari

# Start Ambari server and agent
#$AMBARI_HOME/ambari-server/sbin/ambari-server start
#$AMBARI_HOME/ambari-agent/sbin/ambari-agent start


# Start Spark master and worker
$SPARK_HOME/sbin/start-master.sh
$SPARK_HOME/sbin/start-worker.sh

# Start the SSH server
/usr/sbin/sshd -D &

# Start PostgreSQL
service postgresql start

# Additional commands to start other services if required

# Keep the script running to keep the container alive
tail -f /dev/null
