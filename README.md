# How to Create and Run a Dockerfile with Apache Spark, Ambari, Hadoop, and a PostgreSQL JDBC Server

## Introduction:
Docker is a powerful tool for containerization that allows you to package applications and their dependencies into lightweight, portable containers. In this blog post, we will guide you through the process of creating and running a Dockerfile that includes Apache Spark, Ambari, Hadoop, and a PostgreSQL JDBC server in a single container. We will also upgrade the container to include Maven and run a simple Hello World Scala example compiled with Maven.

## Prerequisites:
Before you begin, make sure you have Docker installed on your machine. You can download and install Docker from the official website (https://www.docker.com/).

## Step 1: Create the Dockerfile for Apache Spark, Ambari, Hadoop, and Maven
Create a new file named `Dockerfile` in your desired directory and open it in a text editor. Copy and paste the following code into the Dockerfile:

```Dockerfile
# Use a base image with Java and Maven pre-installed
FROM maven:3.8.4-jdk-11

# Set environment variables
ENV HADOOP_VERSION 3.3.1
ENV SPARK_VERSION 3.3.3
ENV AMBARI_VERSION 2.7.7
ENV POSTGRES_VERSION 14
ENV JAVA_HOME /usr/local/openjdk-11

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl wget gnupg2 lsb-release openssh-server libsnappy-dev

# Set up SSH server
RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

# Set root password
RUN echo 'root:password' | chpasswd

# Add PostgreSQL repository and key
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Install PostgreSQL
RUN apt-get update && \
    apt-get install -y postgresql-${POSTGRES_VERSION}

# Download and install Hadoop
RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} /usr/local/hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

# Create a non-root user for running Hadoop, YARN, and Spark services
RUN useradd -ms /bin/bash hadoopuser
# Set password for the hadoopuser
RUN echo 'hadoopuser:password' | chpasswd

# Configure Hadoop environment variables
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR ${HADOOP_HOME}/etc/hadoop
ENV HDFS_NAMENODE_USER hadoopuser
ENV HDFS_DATANODE_USER hadoopuser
ENV HDFS_SECONDARYNAMENODE_USER hadoopuser
ENV YARN_RESOURCEMANAGER_USER hadoopuser
ENV YARN_NODEMANAGER_USER hadoopuser
ENV PATH $PATH:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin

# Set JAVA_HOME for Hadoop
RUN echo "export JAVA_HOME=${JAVA_HOME}" >> ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh && \
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh

# Download and install Spark
RUN wget https://downloads.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-without-hadoop.tgz && \
    mv spark-${SPARK_VERSION}-bin-without-hadoop /usr/local/spark && \
    rm spark-${SPARK_VERSION}-bin-without-hadoop.tgz

# Configure Spark environment variables
ENV SPARK_HOME /usr/local/spark
ENV PATH $PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

# Set JAVA_HOME for Spark
RUN mkdir -p ${SPARK_HOME}/conf && \
    echo "export JAVA_HOME=${JAVA_HOME}" >> ${SPARK_HOME}/conf/spark-env.sh && \
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ${SPARK_HOME}/conf/spark-env.sh

# Download SLF4J library
RUN wget https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.7.32/slf4j-api-1.7.32.jar && \
    wget https://repo1.maven.org/maven2/org/slf4j/slf4j-log4j12/1.7.32/slf4j-log4j12-1.7.32.jar

# Copy SLF4J library to Spark jars directory
RUN cp slf4j-api-1.7.32.jar ${SPARK_HOME}/jars/ && \
    cp slf4j-log4j12-1.7.32.jar ${SPARK_HOME}/jars/

# Copy Hadoop AWS dependencies to Spark
RUN cp ${HADOOP_HOME}/share/hadoop/tools/lib/*.jar ${SPARK_HOME}/jars/

# Download and install Ambari
RUN wget https://downloads.apache.org/ambari/ambari-${AMBARI_VERSION}/apache-ambari-${AMBARI_VERSION}-src.tar.gz && \
    tar -xzf apache-ambari-${AMBARI_VERSION}-src.tar.gz && \
    mv apache-ambari-${AMBARI_VERSION}-src /usr/local/ambari && \
    rm apache-ambari-${AMBARI_VERSION}-src.tar.gz

# Set the AMBARI_HOME environment variable
ENV AMBARI_HOME /usr/local/ambari

COPY env.sh /usr/local/bin/env.sh
RUN chmod +x /usr/local/bin/env.sh
# Copy the start-all.sh script to the container
COPY start-all.sh /usr/local/bin/start-all.sh
RUN chmod +x /usr/local/bin/start-all.sh
# Expose necessary ports
EXPOSE 8080 50070 9000 9870 9864 8888 5432 22

#CMD ["/usr/local/bin/start-all.sh"]
CMD ["/bin/bash", "/usr/local/bin/start-all.sh"]

```

Save the Dockerfile.
## Step 2: Create the env.sh Script
Create another file named `env.sh` in the same directory as the Dockerfile. Open it in a text editor and copy the following code:
```bash
export JAVA_HOME=/usr/local/openjdk-11
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
export SPARK_HOME=/usr/local/spark
export HADOOP_CLASSPATH=$(hadoop classpath)
export SPARK_DIST_CLASSPATH=$(${HADOOP_HOME}/bin/hadoop classpath)
export PATH=$PATH:${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin
```


## Create the start-all.sh Script
Create another file named `start-all.sh` in the same directory as the Dockerfile. Open it in a text editor and copy the following code:

```bash
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

```

Save the start-all.sh script.

## Step 3: Build and Run the Docker Image for Apache Spark, Ambari, Hadoop, and Maven
Open your terminal or command prompt 

```
prompt Develop$G
```

and navigate to the directory containing the Dockerfile and start-all.sh script. Run the following commands to build and run the Docker image:

```bash
docker build -t spark-ambari-hadoop .
docker run -d -p 5432:5432 -p 8080:8080 -p 50070:50070 -p 9000:9000 -p 9870:9870 -p 9864:9864 -p 8888:8888 spark-ambari-hadoop
```

The `-t` flag in the build command allows you to specify a name for the image, in this case, `spark-ambari-hadoop`. The `-d` flag in the run command runs the container in detached mode, meaning it will run in the background.

## Step 4: Create the Dockerfile for the PostgreSQL JDBC Server
Create a new file named `Dockerfile-postgres` in the same directory as the previous Dockerfile. Open it in a text editor and copy the following code:

```Dockerfile
# Use the official PostgreSQL image as the base
FROM postgres:latest

# Set environment variables for the PostgreSQL database
ENV POSTGRES_DB mydb
ENV POSTGRES_USER myuser
ENV POSTGRES_PASSWORD mypassword

# Expose the default PostgreSQL port
EXPOSE 5432

# The base PostgreSQL image already includes an entrypoint script
# to initialize and start the PostgreSQL server, so no further
# commands are needed.
```

Save the Dockerfile-postgres.

## Step 5: Build and Run the Docker Image for the PostgreSQL JDBC Server
Open your terminal or command prompt and navigate to the directory containing the Dockerfile-postgres. Run the following commands to build and run the Docker image:

```bash
docker build -t my-postgres-image .
docker run --name my-postgres-container -p 5432:5432 -d my-postgres-image
```

The `-t` flag in the build command allows you to specify a name for the image, in this case, `my-postgres-image`. The `-p` flag in the run command maps the container port 5432 to the host port 5432, allowing you to access the PostgreSQL server.

## Step 6: Create a Simple Hello World Scala Project with Maven
Create a new directory for your Scala project and navigate to it in your terminal or command prompt. Run the following command to create a new Maven project:

```bash
mvn archetype:generate -DgroupId=com.example -DartifactId=my-scala-project -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
```

This will create a new Maven project in a directory named `my-scala-project`. Navigate to the project directory:

```bash
cd my-scala-project
```

## Step 7: Add a Simple Hello World Scala Class
Open the `src/main/scala/com/example/App.scala` file in a text editor and replace its contents with the following code:

```scala
package com.example

object App {
  def main(args: Array[String]): Unit = {
    println("Hello, World!")
  }
}
```

Save the file.

## Step 8: Build the Maven Project
In the terminal or command prompt, run the following command to build the Maven project:

```bash
mvn clean package
```

This will compile the Scala code and package the project into a JAR file.

## Step 9: Run the Maven Project in the Docker Container
Copy the JAR file from the Maven project into the Docker container by running the following command:

```bash
docker cp target/my-scala-project-1.0-SNAPSHOT.jar <container_id>:/app/my-scala-project.jar
```

Replace `<container_id>` with the ID of the running spark-ambari-hadoop container. You can find the container ID by running `docker ps`.

To execute the Scala code in the Docker container, run the following command:

```bash
docker exec <container_id> spark-submit --class com.example.App /app/my-scala-project.jar
```

Replace `<container_id>` with the ID of the running spark-ambari-hadoop container.

Conclusion:
In this blog post, we have learned how to create and run a Dockerfile that includes Apache Spark, Ambari, Hadoop, and a PostgreSQL JDBC server in a single container. We have also upgraded the container to include Maven and demonstrated how to run a simple Hello World Scala example compiled with Maven. This setup allows for easy setup and testing of big data processing and management environments, along with a PostgreSQL database. You can further customize this setup based on your specific requirements and configurations. Happy containerization and big data processing!