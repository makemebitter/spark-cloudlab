#!/bin/bash
duty=${1}
JUPYTER_PASSWORD=${2:-"root"}
set -e
sudo apt-get update;
sudo apt-get install -y openjdk-11-jre-headless scala openssh-server openssh-client syslinux-utils python3-pip socat;
# docker
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
# spark
wget https://archive.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz;
tar xvf spark-2.4.4-bin-hadoop2.7.tgz;
sudo mv spark-2.4.4-bin-hadoop2.7 /usr/local/spark;
echo export PATH="$PATH:/usr/local/spark/bin" > ~/._bashrc;
echo export SPARK_HOME="$PATH:/usr/local/spark" >> ~/._bashrc;
sudo cp /usr/local/spark/conf/spark-env.sh.template /usr/local/spark/conf/spark-env.sh;
sudo cp /usr/local/spark/conf/slaves.template /usr/local/spark/conf/slaves;

pip3 install -r /local/repository/requirements.txt;

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
echo "export PYSPARK_PYTHON=python3.6" | sudo tee -a /usr/local/spark/conf/spark-env.sh;


# Jupyter extension configs
sudo /usr/local/bin/jupyter contrib nbextension install --system ;
sudo /usr/local/bin/jupyter nbextensions_configurator enable --system ;
sudo /usr/local/bin/jupyter nbextension enable code_prettify/code_prettify --system ;
sudo /usr/local/bin/jupyter nbextension enable execute_time/ExecuteTime --system ;
sudo /usr/local/bin/jupyter nbextension enable collapsible_headings/main --system ;
sudo /usr/local/bin/jupyter nbextension enable freeze/main --system ;
sudo /usr/local/bin/jupyter nbextension enable spellchecker/main --system ;




cp ~/._bashrc /local/.bashrc

# Running Spark deamons
if [ "$duty" = "m" ]; then
	sudo bash /usr/local/spark/sbin/start-master.sh
	sudo nohup socat TCP-LISTEN:8081,fork TCP:${LOCAL_IP}:8080 > /dev/null 2>&1 &
	sudo nohup socat TCP-LISTEN:4041,fork TCP:${LOCAL_IP}:4040 > /dev/null 2>&1 &
	sudo nohup docker run --init -p 3000:3000 -v "/:/home/project:cached" theiaide/theia-python:next > /dev/null 2>&1 &
	sudo nohup jupyter notebook --no-browser --ip 0.0.0.0 > /dev/null 2>&1 &


elif [ "$duty" = "s" ]; then
	sudo bash /usr/local/spark/sbin/start-slave.sh $master_ip:7077
	sudo nohup socat TCP-LISTEN:8082,fork TCP:${LOCAL_IP}:8081 > /dev/null 2>&1 &	
fi








