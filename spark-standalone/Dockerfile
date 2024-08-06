#####################################################################################################
# ramtricks/spark-standalone Dockerfile
#
# This file prepares an environment for pySpark studies. It's not recommended you use this on
# production environment.
#
# You can try another versions of Spark, Hadoop and Python since they're available in their
# sources. To do that, edit the config.sh script.
#
# This works preparing a base container to run spark as master and worker. It's controlled
# by start-spark.sh which is copyed into the container. Then, docker-compose rewrite the necessary
# variables to start as 'master' or 'worker'.
#
# License: Artistic2 - This software is free and you can use, modify and distribute according with
# terms of the license.
# More details in https://opensource.org/license/artistic-2-0/
#
#####################################################################################################
# Debian is the best!
FROM debian:12.1 as builder
# Getting arguments from docker build --build-args
# All must be set on config.sh file if you're using build-image.sh script
ARG SPARK_VERSION
ARG HADOOP_VERSION
ARG SPARK_HOME
ARG PYTHON_VERSION
ARG PYTHONHASHEED
ARG SPARK_MASTER_PORT
ARG SPARK_MASTER_WEBUI_PORT
ARG SPARK_LOG_DIR
ARG SPARK_MASTER_LOG
ARG SPARK_WORKER_LOG
ARG SPARK_WORKER_WEBUI_PORT
ARG SPARK_WORKER_PORT
ARG NEW_USER
ARG NEW_USER_PASSWORD
ARG JAVA_HOME

ENV JAVA_HOME=$JAVA_HOME
ENV SPARK_HOME=$SPARK_HOME

# Copying spark/hadoop package from resources dir(local) to /(remote)
# It's recommended you run build-image.sh script instead running Dockerfile directly.
# But, If you want to run this Dockerfile directly, you'll need to download files bellow first. See build-image.sh
# where you can find them
COPY apache-spark.tgz /
COPY python-"$PYTHON_VERSION".tgz /
COPY openjdk11.tar.gz /
# Necessary to stablish the environment
COPY config.sh /
COPY start-spark.sh /
COPY project.sh /
# Add Dependencies for PySpark
RUN apt-get update && apt-get install -y curl vim wget software-properties-common ssh libssh-dev \
    net-tools ca-certificates vim build-essential libffi-dev libncursesw5-dev libgdbm-dev libc6-dev \
    zlib1g-dev libsqlite3-dev tk-dev libssl-dev openssl libbz2-dev
# Installing the disgusting Java 11. OMG!
RUN mkdir -p $JAVA_HOME
RUN tar -xzvmf openjdk11.tar.gz -C $JAVA_HOME
RUN mv $JAVA_HOME/jdk-11/* $JAVA_HOME
RUN rm -rf $JAVA_HOME/jdk-11
# Compiling Python
RUN tar -xzvf /python-3.10.12.tgz && cd /Python-3.10.12 && ./configure && make && make install
## Installing alternative version of Python
RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3.10)" 0
RUN update-alternatives --install "/usr/bin/pip" "pip" "$(which pip3.10)" 0
# Fix the value of PYTHONHASHSEED
# Note: this is needed when you use Python 3.3 or greater
ENV PYTHONHASHSEED=1
# Creating spark base dir into container
RUN mkdir -p $SPARK_HOME
RUN tar -xf /apache-spark.tgz -C $SPARK_HOME --strip-components=1
RUN rm apache-spark.tgz
# Apache spark environment
FROM builder as apache-spark
# Setup SPARK HOME
WORKDIR $SPARK_HOME
# Setting variables for master. They'll all replaced on docker-compose.yml
ENV SPARK_MASTER_PORT=$SPARK_MASTER_PORT \
SPARK_MASTER_WEBUI_PORT=$SPARK_WORKER_WEBUI_PORT \
SPARK_LOG_DIR=$SPARK_HOME/logs \
SPARK_MASTER_LOG=$SPARK_HOME/logs/spark-master.out \
SPARK_WORKER_LOG=$SPARK_HOME/logs/spark-worker.out \
SPARK_WORKER_WEBUI_PORT=$SPARK_WORKER_WEBUI_PORT \
SPARK_WORKER_PORT=$SPARK_WORKER_PORT \
SPARK_MASTER=$SPARK_MASTER \
SPARK_WORKLOAD=$SPARK_WORKLOAD \
SPARK_HOME=$SPARK_HOME

RUN mkdir -p $SPARK_LOG_DIR && \
touch $SPARK_MASTER_LOG && \
touch $SPARK_WORKER_LOG && \
ln -sf /dev/stdout $SPARK_MASTER_LOG && \
ln -sf /dev/stdout $SPARK_WORKER_LOG

# Creating developer environment
ENV DEV_HOME=/home/developer
RUN useradd -md $DEV_HOME -s /usr/bin/bash ${NEW_USER} && echo "${NEW_USER}:${NEW_USER_PASSWORD}" | chpasswd
RUN bash -c "mkdir -p $SPARK_HOME/work"
# TODO Find a better solution for this.
RUN bash -c "chmod 777 $SPARK_HOME/work"

USER $NEW_USER
WORKDIR $DEV_HOME
RUN bash -c "mkdir -p $DEV_HOME/pyspark-apps/"
COPY requirements.txt $DEV_HOME/

RUN bash -c "touch /home/developer/.bashrc"
RUN bash -c "echo 'PATH=\$PATH:/home/\$NEW_USER/.local/bin:/opt/spark/bin' >> /home/developer/.bashrc"
RUN bash -c "python3 -mpip install pip --upgrade"
RUN bash -c "python3 -mpip install -r /home/developer/requirements.txt"

# Exposing ports
EXPOSE 8080 7077 6066

# Starting master
CMD ["/bin/bash", "/start-spark.sh"]
