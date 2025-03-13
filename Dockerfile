FROM ubuntu:latest

# =========================================================
# CREATE SUDO USER:
# =========================================================

# Update and install sudo
RUN apt-get update && apt-get update -y && apt-get install -y sudo

# Create passwordless sudo user `hadoop` and configure sudoers
RUN useradd -m hadoop && echo "hadoop ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch to sudo user
USER hadoop

# =========================================================
# INSTALL JAVA:
# =========================================================

# Install Java and other necessary packages
RUN sudo apt-get update && sudo apt-get update
RUN sudo apt-get install -y bash-completion openjdk-8-jdk wget

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk


# =========================================================
# SETUP SSH CONNECTION:
# =========================================================

# Install SSH and UFW:
RUN sudo apt-get install -y openssh-server ufw

# Create SSH keys:
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys
RUN echo "StrictHostKeyChecking no" >> ~/.ssh/config

# Allow localhost SSH:
RUN sudo ufw allow 22

# Select bash as the default shell for the user
RUN sudo chsh -s /bin/bash hadoop

# =========================================================
# SETUP HADOOP CONFIGURATION:
# =========================================================

# Install Hadoop
WORKDIR /home/hadoop
RUN wget https://downloads.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
RUN tar -xvzf hadoop-3.4.0.tar.gz
RUN mv hadoop-3.4.0 ~/hadoop
RUN rm hadoop-3.4.0.tar.gz

# Set environment variables
ENV HADOOP_HOME=/home/hadoop/hadoop-3.4.0
ENV HADOOP_INSTALL=$HADOOP_HOME
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
ENV PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
ENV HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"

# Set Hadoop version:
RUN mv ~/hadoop ~/hadoop-3.4.0

# Point JAVA_HOME to the installed JDK:
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64

# Set Hadoop User and Group:
RUN sudo chown -R hadoop:hadoop /home/hadoop/hadoop-3.4.0

# =========================================================
# CONTAINER STARTUP COMMAND:
# =========================================================

# Restart ssh service:
ENTRYPOINT [ "/bin/bash", "-c", "sudo service ssh start && hdfs datanode" ]
