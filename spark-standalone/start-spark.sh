#! /usr/bin/env bash
####################################################################################################################
# start-spark.sh
#
# Defines what master/worker deployment will be set when service up
#
# How to use it?
#   Run build-image.sh
#   Then, run docker-compose --env-file=config.sh up
#
####################################################################################################################
if [ -f "/home/develop/.bashrc" ]; 
then

    source /home/develop/.bashrc
fi

source /config.sh

#. "$SPARK_HOME/bin/load-spark-env.sh"
# When the spark work_load is master run class org.apache.spark.deploy.master.Master
if [ "$SPARK_WORKLOAD" == "master" ];
then
    SPARK_MASTER_HOST=`hostname -i`
    export SPARK_MASTER_HOST

    cd "$SPARK_HOME"/bin && ./spark-class org.apache.spark.deploy.master.Master --ip "$SPARK_MASTER_HOST" \
    --port "$SPARK_MASTER_PORT" \
    --webui-port "$SPARK_MASTER_WEBUI_PORT" >> "$SPARK_MASTER_LOG"

elif [ "$SPARK_WORKLOAD" == "worker" ];
then
    # When the spark work_load is worker run class org.apache.spark.deploy.master.Worker $SPARK_MASTER_HOST
    cd /opt/spark/bin && ./spark-class org.apache.spark.deploy.worker.Worker --webui-port "$SPARK_WORKER_WEBUI_PORT" "$SPARK_MASTER" >> "$SPARK_WORKER_LOG"

elif [ "$SPARK_WORKLOAD" == "submit" ];
then
    echo "SPARK SUBMIT"
else
    echo "Undefined Workload Type $SPARK_WORKLOAD, must specify: master, worker or submit"
fi
