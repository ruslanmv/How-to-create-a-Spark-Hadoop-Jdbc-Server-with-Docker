# Use a base image with Java and Maven pre-installed
FROM maven:3.8.4-jdk-11

# Set environment variables
ENV HADOOP_VERSION 3.3.1
ENV SPARK_VERSION 3.3.3
ENV AMBARI_VERSION 2.7.7
ENV POSTGRES_VERSION 14
ENV JAVA_HOME /usr/local/openjdk-11

# Install dependencies
USER root
RUN apt-get update && \
    apt-get install -y curl wget gnupg2 lsb-release openssh-server libsnappy-dev

# Set up SSH server
RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

# Set root password
RUN echo 'root:password' | chpasswd

# Add PostgreSQL repository and key
USER root
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

# Copy Hadoop AWS dependencies to Spark
RUN cp ${HADOOP_HOME}/share/hadoop/tools/lib/*.jar ${SPARK_HOME}/jars/

# Download and install Ambari
RUN wget https://downloads.apache.org/ambari/ambari-${AMBARI_VERSION}/apache-ambari-${AMBARI_VERSION}-src.tar.gz && \
    tar -xzf apache-ambari-${AMBARI_VERSION}-src.tar.gz && \
    mv apache-ambari-${AMBARI_VERSION}-src /usr/local/ambari && \
    rm apache-ambari-${AMBARI_VERSION}-src.tar.gz

# Set the AMBARI_HOME environment variable
ENV AMBARI_HOME /usr/local/ambari

# Copy the start-all.sh script to the container
COPY start-all.sh /usr/local/bin/start-all.sh
RUN chmod +x /usr/local/bin/start-all.sh

# Expose necessary ports
EXPOSE 8080 50070 9000 9870 9864 8888 5432 22

# Start the services and SSH server
CMD ["/usr/local/bin/start-all.sh"]