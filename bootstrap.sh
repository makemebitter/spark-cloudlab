#!/bin/bash

set -e
sudo apt-get update;
sudo apt-get install -y openjdk-11-jre-headless scala openssh-server openssh-client syslinux-utils python3-pip;
wget https://archive.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz;
tar xvf spark-2.4.4-bin-hadoop2.7.tgz;
sudo mv spark-2.4.4-bin-hadoop2.7 /usr/local/spark;
echo export PATH="$PATH:/usr/local/spark/bin" >> ~/.bashrc;
echo export SPARK_HOME="$PATH:/usr/local/spark" >> ~/.bashrc;
source ~/.bashrc;
sudo cp /usr/local/spark/conf/spark-env.sh.template /usr/local/spark/conf/spark-env.sh;
sudo cp /usr/local/spark/conf/slaves.template /usr/local/spark/conf/slaves;

pip3 install -y pyspark==2.4.4

ips=($(ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}'))
for ip in "${ips[@]}"
do
    if [[ $ip == *"10."* ]]; then
        echo export LOCAL_IP=$ip >> ~/.bashrc;  
    fi
done

master_ip=$(gethostip -d master);
echo "export SPARK_MASTER_HOST=$master_ip" | sudo tee -a /usr/local/spark/conf/spark-env.sh;
echo "export SPARK_LOCAL_IP=$LOCAL_IP" | sudo tee -a /usr/local/spark/conf/spark-env.sh;
echo "export PYSPARK_PYTHON=python3.6" | sudo tee -a /usr/local/spark/conf/spark-env.sh;

echo "worker-0" | sudo tee -a /usr/local/spark/conf/slaves;




