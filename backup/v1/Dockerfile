
# Use a base image with Java and Maven pre-installed
FROM maven:3.8.4-jdk-11
# Set environment variables
ENV HADOOP_VERSION 3.3.1
ENV SPARK_VERSION 3.3.3
ENV AMBARI_VERSION 2.7.7

# Update packages and install dependencies
RUN apt-get update && \
    apt-get install -y curl wget openssh-server

# Set up SSH server
RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

# Set root password
RUN echo 'root:password' | chpasswd

# Expose SSH port
EXPOSE 22

# Download and install Hadoop
RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} /usr/local/hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

# Configure Hadoop environment variables
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR ${HADOOP_HOME}/etc/hadoop
ENV PATH $PATH:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin

# Download and install Spark
RUN wget https://downloads.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-without-hadoop.tgz && \
    mv spark-${SPARK_VERSION}-bin-without-hadoop /usr/local/spark && \
    rm spark-${SPARK_VERSION}-bin-without-hadoop.tgz

# Configure Spark environment variables
ENV SPARK_HOME /usr/local/spark
ENV PATH $PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

# Download and install Ambari
RUN wget https://downloads.apache.org/ambari/ambari-${AMBARI_VERSION}/apache-ambari-${AMBARI_VERSION}-src.tar.gz && \
    tar -xzf apache-ambari-${AMBARI_VERSION}-src.tar.gz && \
    mv apache-ambari-${AMBARI_VERSION}-src /usr/local/ambari && \
    rm apache-ambari-${AMBARI_VERSION}-src.tar.gz

# Configure Ambari environment variables
ENV AMBARI_HOME /usr/local/ambari
ENV PATH $PATH:${AMBARI_HOME}/bin

# Copy the start-all.sh script to the container
COPY start-all.sh /usr/local/bin/start-all.sh
RUN chmod +x /usr/local/bin/start-all.sh

# Expose necessary ports
EXPOSE 8080 50070 9000 9870 9864 8888

# Start the services and SSH server
CMD ["/usr/local/bin/start-all.sh"]
