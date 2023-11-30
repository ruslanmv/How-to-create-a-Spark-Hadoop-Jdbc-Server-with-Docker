docker build --no-cache  -t spark-ambari-hadoop . 
docker run -d -p 22:22 --name spark_ambari_hadoop_container spark-ambari-hadoop
docker logs spark_ambari_hadoop_container 
#ssh root@localhost -p 22
#ssh hadoopuser@localhost -p 22

