#! /usr/bin/env bash
##########################################################################################################
# build-image.sh: Downloads the chosen Spark/Hadoop version file and Python version from Apache official
#                 download site, set on 'config.sh' file. Then, run "docker build" command.
# Dependencies:  config.sh, project.sh
# Usage:
# source config.sh && ./build-image.sh
##########################################################################################################

# Getting config from config.sh file. Check/Edit it first to run this script!
source project.sh
source config.sh

function download() {
  url=$1
  output_name=$2
  if [ -z "$url" ]; then
    echo "URL can't be empty on download"
  fi
  wget_result="$(wget -NS "$url" 2>&1|grep "HTTP/"|awk '{print $2}') -O $output_name"
  if [ "$wget_result" == 200 ]; then
    echo "File downloaded"
    echo ""
  elif [ "$wget_result" == 304 ]; then
    echo "File not modified from local copy"
  else
      echo "Something went wrong downloading $url - status code($wget_result)"
      exit 1
  fi
}

# Checking for environment variables
if [[ -z "$SPARK_VERSION" || -z "$HADOOP_VERSION" || -z "$PYTHON_VERSION" ]];then
    echo "ERROR: The variables 'SPARK_VERSION', 'HADOOP_VERSION' AND 'PYTHON_VERSION'  must be set first! Exiting!"
    exit 1
fi

echo "Spark version is $SPARK_VERSION with Hadoop $HADOOP_VERSION"
# Downloading Spark version
echo "Checking Spark file"
if [ ! -f apache-spark.tgz ]; then
    echo "Downloading Apache Spark $SPARK_VERSION with Hadoop $HADOOP_VERSION"
    wget -O apache-spark.tgz "https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz"
#    spark_address="https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz"
    download "$spark_address" "apache-spark.tgz"
else
    echo "File apache-spark.tgz already exists"
fi

## Downloading Python
python_address="https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz"
python_file="python-$PYTHON_VERSION.tgz"
echo "Checking Python source file"
if [ ! -f "$python_file" ]; then
    echo "Downloading $python_file "
#    wget -O python-"$PYTHON_VERSION".tgz "$python_address" -O python-"$PYTHON_VERSION".tgz
    download "$python_address" "python-${PYTHON_VERSION}.tgz"
else
    echo "File '$python_file' already exists"
fi

# Downloading the disgusting Java
openjdk_link="https://download.java.net/openjdk/jdk11/ri/openjdk-11+28_linux-x64_bin.tar.gz"
java_file="openjdk11.tar.gz"
echo "Checking $java_file"
if [ ! -f "$java_file" ]; then
  echo "Downloading Java from $openjdk_link"
#    wget -O "$java_file" "$openjdk_link"
  download "$openjdk_link" "$java_file"
else
    echo "File '$java_file' is already downloaded!"
fi

# Building image
echo "Building docker image $IMAGE_VERSION"
echo "SPARK VERSION IS $SPARK_VERSION"
echo "HADOOP VERSION IS $HADOOP_VERSION"
echo "PYTHON VERSION IS $PYTHON_VERSION"
# Exporting docker_command
docker_command="docker build \
--build-arg SPARK_VERSION=$SPARK_VERSION \
--build-arg HADOOP_VERSION=$HADOOP_VERSION \
--build-arg PYTHON_VERSION=$PYTHON_VERSION \
--build-arg SPARK_HOME=$SPARK_HOME \
--build-arg TZ_STR=$TZ_STR \
--build-arg SPARK_HOME=$SPARK_HOME \
--build-arg SPARK_MASTER_PORT=$SPARK_MASTER_PORT \
--build-arg SPARK_WORKER_WEBUI_PORT=$SPARK_WORKER_WEBUI_PORT \
--build-arg SPARK_WORKER_PORT=$SPARK_WORKER_PORT \
--build-arg JAVA_HOME=$JAVA_HOME \
--build-arg NEW_USER=$NEW_USER \
--build-arg NEW_USER_PASSWORD=$NEW_USER_PASSWORD"
# Checking if --no-cache will be included. It's set on config.sh
if [ "$DOCKER_NO_CACHE" == 1 ]
then
  docker_command="$docker_command --no-cache"
fi
# Including the image tag
docker_command="$docker_command -t $IMAGE_VERSION ."
# Running docker command
echo "Building the docker image $IMAGE_VERSION"
bash -c "$docker_command"

echo ""
echo "Done!"
echo ""

exit 0
