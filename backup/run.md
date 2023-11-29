The issue may be caused by the fact that the SSH server is starting in the foreground at the end of the `start-all.sh` script. To fix this issue, you can modify the `start-all.sh` script to start the SSH server in the background by adding an ampersand `&` after the SSH server command:

```
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

# Start the SSH server
/usr/sbin/sshd -D &

# Start PostgreSQL
service postgresql start

# Additional commands to start other services if required
# Keep the script running to keep the container alive
tail -f /dev/null
```

After updating the `start-all.sh` script, rebuild the Docker image and run the container:

```
docker build --no-cache  -t spark-ambari-hadoop . 

docker run -d -p 22:22 -p 8080:8080 -p 50070:50070 -p 9000:9000 -p 9870:9870 -p 9864:9864 -p 8888:8888 --name spark_ambari_hadoop_container spark-ambari-hadoop
```

```
docker run -d -p 22:22 --name spark_ambari_hadoop_container spark-ambari-hadoop
```
https://cwiki.apache.org/confluence/display/AMBARI/Installation+Guide+for+Ambari+2.7.7

```
docker logs spark_ambari_hadoop_container
```

Now, you should be able to SSH into the container:

```
ssh root@localhost -p 22
```

Enter the password you set in the Dockerfile when prompted.