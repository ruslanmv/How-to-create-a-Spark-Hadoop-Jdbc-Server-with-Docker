docker build --no-cache  -t spark-ambari-hadoop . 
docker run -d -p 22:22 --name spark_ambari_hadoop_container spark-ambari-hadoop
ssh root@localhost -p 22
docker logs spark_ambari_hadoop_container 
