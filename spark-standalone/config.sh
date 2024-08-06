#! /usr/bin/env bash
#######################################################################################################################
# config.sh - Setup version of ecosystem applications(Spark, Hadoop and Python), SPARK_HOME, and the image name/version
#             of the docker image which will be built by build-image.sh
# USE: source config.sh && docker-compose up
#######################################################################################################################
# Loading project metadata
source project.sh
# Verison vars
export SPARK_VERSION="3.2.4"
export HADOOP_VERSION="3.2"
export PYTHON_VERSION="3.10.12"
# Docker Tag version
export IMAGE_TAG="$PROJECT_VERSION"
# System vars
export TZ_STR=America/Sao_Paulo
export NEW_USER="developer"
export NEW_USER_PASSWORD="Dev#1842"
# Spark config vars
export SPARK_HOME=/opt/spark
export SPARK_MASTER_PORT=7077
export SPARK_WORKER_WEBUI_PORT=8080
export SPARK_WORKER_PORT=7000
# Java home in containers
export JAVA_HOME=/opt/java
# Docker no-cache option
export DOCKER_NO_CACHE=1
# Set ramtricks image tag name
export IMAGE_VERSION="ramtricks/spark-stda-$SPARK_VERSION-hadoop-$HADOOP_VERSION-python-$PYTHON_VERSION:$IMAGE_TAG"
