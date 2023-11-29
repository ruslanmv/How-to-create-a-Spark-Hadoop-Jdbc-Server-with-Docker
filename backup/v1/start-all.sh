#!/bin/bash

# Start Hadoop services
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

# Start Ambari server and agent
$AMBARI_HOME/sbin/ambari-server start
$AMBARI_HOME/sbin/ambari-agent start

# Start Spark master and worker
$SPARK_HOME/sbin/start-master.sh
$SPARK_HOME/sbin/start-worker.sh


# Start PostgreSQL
service postgresql start

# Additional commands to start other services if required

# Keep the script running to keep the container alive
tail -f /dev/null