# Use a base image with Java and Maven pre-installed
FROM maven:3.8.4-jdk-11

# Set environment variables
ENV HADOOP_VERSION 3.3.1
ENV SPARK_VERSION 3.3.3
ENV AMBARI_VERSION 2.7.7
ENV POSTGRES_VERSION 14

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl wget gnupg2 lsb-release

# Add PostgreSQL repository and key
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Install PostgreSQL
RUN apt-get update && \
    apt-get install -y postgresql-${POSTGRES_VERSION}

# Download and install Hadoop
#https://downloads.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz
RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} /usr/local/hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

# Configure Hadoop environment variables
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR ${HADOOP_HOME}/etc/hadoop
ENV PATH $PATH:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin

# Download and install Spark
#https://downloads.apache.org/spark/spark-3.3.3/spark-3.3.3-bin-without-hadoop.tgz
RUN wget https://downloads.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-without-hadoop.tgz && \
    mv spark-${SPARK_VERSION}-bin-without-hadoop /usr/local/spark && \
    rm spark-${SPARK_VERSION}-bin-without-hadoop.tgz

# Configure Spark environment variables
ENV SPARK_HOME /usr/local/spark
ENV PATH $PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

# Download and install Ambari
#https://downloads.apache.org/ambari/ambari-2.7.7/apache-ambari-2.7.7-src.tar.gz

RUN wget https://downloads.apache.org/ambari/ambari-${AMBARI_VERSION}/apache-ambari-${AMBARI_VERSION}-src.tar.gz && \
    tar -xzf apache-ambari-${AMBARI_VERSION}-src.tar.gz && \
    mv apache-ambari-${AMBARI_VERSION}-src /usr/local/ambari && \
    rm apache-ambari-${AMBARI_VERSION}-src.tar.gz

# Configure Ambari environment variables
ENV AMBARI_HOME /usr/local/ambari
ENV PATH $PATH:${AMBARI_HOME}/bin

# Expose necessary ports
EXPOSE 8080 50070 9000 9870 9864 8888  5432

# Set the working directory for the Maven project
WORKDIR /app

# Copy the Maven project to the container
#COPY . .

# Build the Maven project
#RUN mvn clean package

# Start the services
CMD ["start-all.sh"]