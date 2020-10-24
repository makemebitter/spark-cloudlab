duty=${1}
sudo apt-get update;
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install -y openjdk-8-jre-headless scala openssh-server openssh-client syslinux-utils python3-pip socat;
wget https://archive.apache.org/dist/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz;
tar xvf spark-2.4.5-bin-hadoop2.7.tgz;
sudo mv spark-2.4.5-bin-hadoop2.7 /usr/local/spark;
echo export PATH="$PATH:/usr/local/spark/bin" > ~/.bashrc;
echo export SPARK_HOME="$PATH:/usr/local/spark" >> ~/.bashrc;
sudo cp /usr/local/spark/conf/spark-env.sh.template /usr/local/spark/conf/spark-env.sh;
sudo cp /usr/local/spark/conf/slaves.template /usr/local/spark/conf/slaves;

sudo python3.7 -m pip install --upgrade --force-reinstall setuptools

sudo python3.7 -m pip install -r ./requirements.txt;

HADOOP_HOME=/local/hadoop
mkdir $HADOOP_HOME
HOST_LIST_PATH=/local/gphost_list
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")

wget https://archive.apache.org/dist/hadoop/core/hadoop-2.7.3/hadoop-2.7.3.tar.gz
tar -xvf hadoop-2.7.3.tar.gz 
cp -r hadoop-2.7.3/. $HADOOP_HOME/.
sudo cp $HOST_LIST_PATH $HADOOP_HOME/etc/hadoop/slaves

echo "master" | sudo tee $HADOOP_HOME/etc/hadoop/workers
echo "export HADOOP_HOME=$HADOOP_HOME" | sudo tee -a ~/.bashrc
echo "export HADOOP_PREFIX=$HADOOP_HOME" | sudo tee -a ~/.bashrc
echo "export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin" | sudo tee -a ~/.bashrc
source ~/.bashrc
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a $HADOOP_HOME/etc/hadoop/hadoop-env.sh
cp core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
cp yarn-site.xml /local/hadoop/etc/hadoop/yarn-site.xml
cp hdfs-site.xml /local/hadoop/etc/hadoop/hdfs-site.xml
# Spark ips configs
ips=($(ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}'))
for ip in "${ips[@]}"
do
    if [[ $ip == *"10."* ]]; then
        echo export LOCAL_IP=$ip >> ~/._bashrc;
        LOCAL_IP=$ip
    fi
done
master_ip=$(gethostip -d master);
echo "export SPARK_MASTER_HOST=$master_ip" | sudo tee -a /usr/local/spark/conf/spark-env.sh;
echo "export SPARK_LOCAL_IP=$LOCAL_IP" | sudo tee -a /usr/local/spark/conf/spark-env.sh;
echo "export PYSPARK_PYTHON=python3.7" | sudo tee -a /usr/local/spark/conf/spark-env.sh;