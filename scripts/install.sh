#!/usr/bin/env bash

SPARK_VERSION=1.3.1
ELASTICSEARCH_VERSION=1.4.4
ELASTICSEARCH_HADOOP_VERSION=2.0.2
MAHOUT_VERSION=0.10.0
MAVEN_VERSION=3.3.3
HADOOP_VERSION=2.7.0
PIG_VERSION=0.14.0
RUBY_VERSION=2.2.2

VENDORS_DIR=$HOME/vendors
SPARK_DIR=${VENDORS_DIR}/spark-${SPARK_VERSION}
MAHOUT_DIR=${VENDORS_DIR}/mahout-${MAHOUT_VERSION}
ELASTICSEARCH_DIR=${VENDORS_DIR}/elasticsearch-${ELASTICSEARCH_VERSION}
ELASTICSEARCH_HADOOP_DIR=${VENDORS_DIR}/elasticsearch-hadoop-${ELASTICSEARCH_HADOOP_VERSION}
MAVEN_DIR=${VENDORS_DIR}/maven-${MAVEN_VERSION}
HADOOP_DIR=${VENDORS_DIR}/hadoop-${HADOOP_VERSION}
PIG_DIR=${VENDORS_DIR}/pig-${PIG_VERSION}

INSTALLED_FLAG=$HOME/installed

if [ ! -f $INSTALLED_FLAG ]; then
  
  echo "Provisioning..."
  
  sudo apt-get update
  sudo apt-get install -y vim git build-essential unzip
  
  # Java
  sudo apt-get install -y openjdk-7-jdk
  echo 'export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' >> ~/.bashrc
  echo -e "\033[1;32mJava install done!\033[0m"
  
  mkdir ${VENDORS_DIR}
  
  # Spark
  echo -e "\033[1;36mStarting Spark setup in:\033[0m $spark_dir"
  if [[ -e spark-${SPARK_VERSION}-bin-hadoop2.6.tgz ]]; then
    if confirm "Delete existing spark-$SPARK_VERSION-bin-hadoop2.6.tgz?"; then
      rm spark-${SPARK_VERSION}-bin-hadoop2.6.tgz
    fi
  fi
  if [[ ! -e spark-${SPARK_VERSION}-bin-hadoop2.6.tgz ]]; then
    echo "Downloading Spark..."
    curl -O http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VERSION}-bin-hadoop2.6.tgz
  fi
  tar xf spark-${SPARK_VERSION}-bin-hadoop2.6.tgz
  rm -rf ${SPARK_DIR}
  mv spark-${SPARK_VERSION}-bin-hadoop2.6 ${SPARK_DIR}
  echo "export SPARK_HOME=${SPARK_DIR}" >> ~/.bashrc
  echo 'export PATH=$PATH:'${SPARK_DIR}'/bin' >> ~/.bashrc
  echo -e "\033[1;32mSpark setup done!\033[0m"
  
  # Elasticsearch
  echo -e "\033[1;36mStarting Elasticsearch setup in:\033[0m $ELASTICSEARCH_DIR"
  if [[ -e elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz ]]; then
    if confirm "Delete existing elasticsearch-$ELASTICSEARCH_VERSION.tar.gz?"; then
      rm elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz
    fi
  fi
  if [[ ! -e elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz ]]; then
    echo "Downloading Elasticsearch..."
    curl -O https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz
  fi
  tar zxf elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz
  rm -rf ${ELASTICSEARCH_DIR}
  mv elasticsearch-${ELASTICSEARCH_VERSION} ${ELASTICSEARCH_DIR}
  echo "Updating: $ELASTICSEARCH_DIR/config/elasticsearch.yml"
  echo 'network.host: 127.0.0.1' >> ${ELASTICSEARCH_DIR}/config/elasticsearch.yml
  echo 'export PATH=$PATH:'${ELASTICSEARCH_DIR}'/bin' >> ~/.bashrc
  echo 'eval "$(elasticsearch -d -p ~/tmp/pids/elasticsearch.pid)"' >> ~/.bashrc
  echo -e "\033[1;32mElasticsearch setup done!\033[0m"
  
  # Mahout
  echo -e "\033[1;32mStarting Mahout setup\033[0m"
  curl -O http://ftp.unicamp.br/pub/apache/mahout/${MAHOUT_VERSION}/mahout-distribution-${MAHOUT_VERSION}.tar.gz
  tar zxf mahout-distribution-${MAHOUT_VERSION}.tar.gz
  rm -rf ${MAHOUT_DIR}
  mv mahout-distribution-${MAHOUT_VERSION} ${MAHOUT_DIR}
  echo "export MAHOUT_HOME=${MAHOUT_DIR}" >> ~/.bashrc
  echo "export MAHOUT_LOCAL=true" >> ~/.bashrc
  echo 'export PATH=$PATH:'${MAHOUT_DIR}'/bin' >> ~/.bashrc
  echo -e "\033[1;32mMahout setup done!\033[0m"
  
  # Maven
  echo -e "\033[1;32mStarting Maven setup\033[0m"
  curl -O http://ftp.unicamp.br/pub/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
  tar zxf apache-maven-${MAVEN_VERSION}-bin.tar.gz
  rm -rf ${MAVEN_DIR}
  mv apache-maven-${MAVEN_VERSION} ${MAVEN_DIR}
  echo 'export PATH=$PATH:'${MAVEN_DIR}'/bin' >> ~/.bashrc
  echo -e "\033[1;32mMaven setup done!\033[0m"
  
  # Hadoop
  echo -e "\033[1;32mStarting Hadoop setup\033[0m"
  curl -O http://ftp.unicamp.br/pub/apache/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
  tar zxf hadoop-${HADOOP_VERSION}.tar.gz
  rm -rf ${HADOOP_DIR}
  mv hadoop-${HADOOP_VERSION} ${HADOOP_DIR}
  echo "export HADOOP_HOME=${HADOOP_DIR}" >> ~/.bashrc
  echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> ~/.bashrc
  echo -e "\033[1;32mHadoop setup done!\033[0m"
  
  # Pig
  echo -e "\033[1;32mStarting Pig setup\033[0m"
  curl -O http://ftp.unicamp.br/pub/apache/pig/pig-${PIG_VERSION}/pig-${PIG_VERSION}.tar.gz
  tar zxf pig-${PIG_VERSION}.tar.gz
  rm -rf ${PIG_DIR}
  mv pig-${PIG_VERSION} ${PIG_DIR}
  echo "export PIG_HOME=${PIG_DIR}" >> ~/.bashrc
  echo 'export PATH=$PATH:$PIG_HOME/bin' >> ~/.bashrc
  echo -e "\033[1;32mPig setup done!\033[0m"
  
  # Elasticsearch for Hadoop connector (es-hadoop)
  echo -e "\033[1;32mStarting Elasticsearch for Hadoop setup\033[0m"
  curl -O http://download.elastic.co/hadoop/elasticsearch-hadoop-${ELASTICSEARCH_HADOOP_VERSION}.zip
  unzip elasticsearch-hadoop-${ELASTICSEARCH_HADOOP_VERSION}.zip
  rm -rf ${ELASTICSEARCH_HADOOP_DIR}
  mv elasticsearch-hadoop-${ELASTICSEARCH_HADOOP_VERSION} ${ELASTICSEARCH_HADOOP_DIR}
  # Adding Pig connector .jar to "pig.additional.jars", so Pig can talk to EL:
  echo "pig.additional.jars=${ELASTICSEARCH_HADOOP_DIR}/dist/elasticsearch-hadoop-pig-${ELASTICSEARCH_HADOOP_VERSION}.jar" >> ${PIG_DIR}/conf/pig.properties
  echo -e "\033[1;32mElasticsearch for Hadoop setup done!\033[0m"
  
  echo -e "\033[1;32mStarting Ruby setup...\033[0m"
  
  # rbenv
  git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
  echo 'export PATH=$PATH:'$HOME'/.rbenv/bin' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  
  # Ruby build
  git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
  sudo apt-get install -y zlib1g-dev libssl-dev libreadline6-dev libyaml-dev
  
  # Ruby
  ~/.rbenv/bin/rbenv install ${RUBY_VERSION}
  ~/.rbenv/bin/rbenv global ${RUBY_VERSION}
  
  echo -e "\033[1;32mRuby setup done!\033[0m"
  
  # Extract data
  echo -e "\033[1;32mExtracting data files in data/\033[0m"
  (cd data/; tar zxf video_views.tar.gz)
  (cd data/; tar zxf videos.tar.gz)
  echo -e "\033[1;32mDone./\033[0m"
  
  echo -e "\033[1;32mStarting Elasticsearch... Please wait some minutes before it's available.\033[0m"
  ${ELASTICSEARCH_DIR}/bin/elasticsearch -d -p ~/tmp/pids/elasticsearch.pid
  
  touch $INSTALLED_FLAG
  
  exec $SHELL
  
else
  echo -e "\033[1;32mAlready provisioned. Skip installation.\033[0m"
fi
