# ramtricks/spark-standalone

Basic environment for studies in pySpark


# Version
0.0.4

# Intro

The information here allows Spark students and enthusiasts to have a basic environment
for studying and test ideas based on PySpark API. 
 
# Features
 - Parametrized(customizable) config
 - Container based on Debian 12.1 stable
 - Python compiled from the source code
 - Default Spark version 3.4.2
 - Default Hadoop version 3.2

# Requirements for this tutorial
 - Debian-based Linux distribution
 - Docker/docker-compose
 - Python >=3.7 **with virtualenv installed**


---


# Not so "straight-forward install"

## Setup docker in your machine
    
 **If you already have Docker configured in your system, just jump to the next section!**

 You can find the Docker official instructions [here](https://docs.docker.com/engine/install/ubuntu/) 

 Or follow my instructions, up to you!


 1. Remove the default Docker packages of your system

```bash
sudo apt purge docker.io docker-doc docker-compose podman-docker containerd runc
```

 2. Prepare your environment
 
```bash
sudo apt update && sudo apt install -y ca-certificates curl gnupg
```

 3. Add the necessary keys for the Docker repos

```bash
sudo install -m 0755 -d /etc/apt/keyrings \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```
 
 4. Add the official Docker repositories

```bash
echo \
"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

 5. Finally, reinstall Docker

```bash
sudo apt update \ 
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
 
 6. Add your user into docker group. Why? Because there is no reason to be execute `sudo` to run Docker in your personal studying machine setup.

```bash
sudo usermod -aG docker <YOUR_USERNAME>
```

 7. Reboot your machine(Yeah, I know! But, it's easier that way)

 
 8. Check if docker it's working


 You can check if it's working running the command `docker --version`. If something is wrong, you're in trouble!
Check your previous steps and try again!

 If the version appears with no errors, you're probably good!

 
# Setup version of things and docker image build

Open the file called `config.sh`. You should see this:

```bash
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

```
### Python version
**ATTENTION**: You need to keep in mind that Python version in your local machine must be the same version on Spark cluster. So, 
check out the local Python version first and change it on config.sh

# Building the Docker image

Finally, let's build it!

`source config.sh && ./build-image.sh`

# Up the container cluster

Now, run the command: `source config.sh && docker-compose up`

Don't worry about "warning" messages!

You should see a line like this

```bash
INFO MasterWebUI: Bound MasterWebUI to spark-master, and started at http://2f8eed8abb75:8080
```

You'll need the master id from this http address. In this case, 2f8eed8abb75. 


<a id="Testing Spark"></a>
# Testing Spark

* Run `docker ps -a` and check if you see something like this:

    ```bash
    CONTAINER ID   IMAGE                                                    COMMAND                  CREATED       STATUS                    PORTS                                                                                                      NAMES
    2190ae9a8d61   ramtricks/spark-standalone-spark3.0.2-hadoop-3.2:0.0.4   "/bin/bash /start-sp…"   2 hours ago   Up 45 minutes             6066/tcp, 7077/tcp, 0.0.0.0:7000->7000/tcp, :::7000->7000/tcp, 0.0.0.0:9096->8080/tcp, :::9096->8080/tcp   spark-standalone-spark-worker-a-1
    ca87b68ff332   ramtricks/spark-standalone-spark3.0.2-hadoop-3.2:0.0.4   "/bin/bash /start-sp…"   2 hours ago   Up 45 minutes             6066/tcp, 7077/tcp, 0.0.0.0:7001->7000/tcp, :::7001->7000/tcp, 0.0.0.0:9097->8080/tcp, :::9097->8080/tcp   spark-standalone-spark-worker-b-1
    2b7ae5f206dc   ramtricks/spark-standalone-spark3.0.2-hadoop-3.2:0.0.4   "/bin/bash /start-sp…"   2 hours ago   Up 45 minutes             6066/tcp, 0.0.0.0:7077->7077/tcp, :::7077->7077/tcp, 0.0.0.0:9095->8080/tcp, :::9095->8080/tcp             spark-standalone-spark-master-1
    
    
    ```

If you see any "Exited" word, that means the Spark service is off and something wrong happened. You'll have to check 
the screen log and check your steps again.


* If everything is running, you can call pyspark using the id of the 'master' container for testing using the command

    `docker exec -it 2b7ae5f206dc bash -c "/opt/spark/current/bin/pyspark"`

You should see something like this:

```text
Python 3.7.3 (default, Jun 29 2023, 18:03:57) 
[GCC 8.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
WARNING: An illegal reflective access operation has occurred
WARNING: Illegal reflective access by org.apache.spark.unsafe.Platform (file:/opt/spark/3.0.2/jars/spark-unsafe_2.12-3.0.2.jar) to constructor java.nio.DirectByteBuffer(long,int)
WARNING: Please consider reporting this to the maintainers of org.apache.spark.unsafe.Platform
WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
WARNING: All illegal access operations will be denied in a future release
23/07/02 14:37:11 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /__ / .__/\_,_/_/ /_/\_\   version 3.2.4
      /_/

Using Python version 3.7.3 (default, Jun 29 2023 18:03:57)
SparkSession available as 'spark'.
```

You're ready to go!


# Setup and start Jupyter

Go to the 'apps' directory and follow the steps below.

1. Create a virtualenv environment

`python -mpip virtualenv venv`

2. Activate virtuaenv environment

`source venv/bin/activate`

3. Create a requirements.txt file(dependencies file)

```txt
pyspark==3.2.4
numpy
scikit-learn
pandas==1.5.3
polars
jupyter
jupyterlab
pyarrow

```

6. Install dependencies


 `python -mpip install -r requirements.txt`


7. Run `jupyter-lab` or `jupyter-notebook` 


8. pySpark example application

```python
# Importing libs
import pyspark
import pyspark.sql.functions as F
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType

# Remember the "master id"? You'll need it now!
spark = SparkSession.builder \
.appName('test001').master("spark://127.0.0.1:7077")\
.getOrCreate()

# Creating a basic schema
schema = StructType([
    StructField('target', StringType(), True)
])
# Let's order this string
data = [['XADOWPQ']]
df = spark.createDataFrame(data, schema) \
.withColumn('target', F.split('target','')) \
.withColumn('target', F.array_sort('target')) \
.withColumn('target', F.concat_ws('', 'target'))
df.show()

```

The output must be this

```text
+-------+
| target|
+-------+
|ADOPQWX|
+-------+

```

If you see this, you're done! If don't, you need to review your steps and try again!


# Future
- Full automatic install


# Bugs

No bugtrack is defined yet.


# Author

[André Garcia Carneiro](mailto:andregarciacarneiro@gmail.com)


# License

Artistic2

