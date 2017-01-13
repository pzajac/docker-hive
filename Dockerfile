FROM ubuntu:latest
MAINTAINER Nagasuga

# update and install basic tools
RUN \
    sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \   
    apt-get update && apt-get upgrade -y
RUN apt-get install -yq curl software-properties-common && \
    apt-get install -yq python

# install java
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


# install hadoop
RUN mkdir /usr/local/hadoop
RUN curl -s http://apache.claz.org/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz | tar -xz -C /usr/local/hadoop --strip-components 1
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_INSTALL $HADOOP_HOME
ENV PATH $PATH:$HADOOP_INSTALL/sbin
ENV HADOOP_MAPRED_HOME $HADOOP_INSTALL
ENV HADOOP_COMMON_HOME $HADOOP_INSTALL
ENV HADOOP_HDFS_HOME $HADOOP_INSTALL
ENV YARN_HOME $HADOOP_INSTALL
ENV PATH $HADOOP_HOME/bin:$PATH


# install hive
RUN mkdir /usr/local/hive
RUN curl -s http://apache.mesi.com.ar/hive/hive-2.1.1/apache-hive-2.1.1-bin.tar.gz | tar -xz -C /usr/local/hive --strip-components 1
ENV HIVE_HOME /usr/local/hive
ENV PATH $HIVE_HOME/bin:$PATH
COPY hive-site.xml $HIVE_HOME/conf/
# TODO move log to other location
RUN cd $HIVE_HOME/hcatalog/ && mkdir var && mkdir var/log


#download derby
RUN mkdir /usr/local/derby
RUN curl -s http://archive.apache.org/dist/db/derby/db-derby-10.10.2.0/db-derby-10.10.2.0-bin.tar.gz | tar -xz -C /usr/local/derby --strip-components 1
RUN mkdir /usr/local/derby/data
ENV DERBY_INSTALL /usr/local/derby
ENV DERBY_HOME /usr/local/derby
RUN cp $DERBY_HOME/lib/derbyclient.jar $HIVE_HOME/lib/ 
RUN cp $DERBY_HOME/lib/derbytools.jar $HIVE_HOME/lib/ 

RUN printf "\n\
echo Aliases: \n\
echo ------------ \n\
echo derbystart -  start derby db for schema\n\
alias derbystart='$DERBY_HOME/bin/startNetworkServer -h 127.0.0.1 &'\n\
echo hiveschema - initialize hive schema with derby\n\
alias hiveschema='$HIVE_HOME/bin/schematool -initSchema -dbType derby'\n\
echo hivejdbc - connect to hive via jdbc\n\
alias hivejdbc='$HIVE_HOME/bin/beeline -u  jdbc:hive2://localhost:10000'\n\
echo hiveserver - start hive server\n\
alias hiveserver='$HIVE_HOME/bin/hiveserver2'\n\
" >>$HOME/.bashrc

    

