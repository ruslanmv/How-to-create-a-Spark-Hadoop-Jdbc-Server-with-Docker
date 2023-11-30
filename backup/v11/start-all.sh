#!/bin/bash

# Load environment variables
source /usr/local/bin/env.sh

# Start Hadoop services
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

# Start Spark master and worker
$SPARK_HOME/sbin/start-master.sh

# Start the SSH server
/usr/sbin/sshd -D &

# Start PostgreSQL
service postgresql start

# Additional commands to start other services if required

# Keep the script running to keep the container alive
tail -f /dev/null
