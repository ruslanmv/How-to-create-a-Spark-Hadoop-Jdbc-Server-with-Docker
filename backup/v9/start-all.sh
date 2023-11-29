#!/bin/bash
# Set Java home
export JAVA_HOME=/usr/local/openjdk-11
#$SPARK_HOME/sbin/start-worker.sh
# Start the SSH server
/usr/sbin/sshd -D &
# Start PostgreSQL
service postgresql start
# Additional commands to start other services if required
# Keep the script running to keep the container alive
tail -f /dev/null