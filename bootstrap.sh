#!/bin/bash
duty=${1}
JUPYTER_PASSWORD=${2:-"root"}
set -e
sudo apt-get update;
sudo apt-get install -y openjdk-11-jre-headless scala openssh-server openssh-client syslinux-utils python3-pip socat;
wget https://archive.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz;
tar xvf spark-2.4.4-bin-hadoop2.7.tgz;
sudo mv spark-2.4.4-bin-hadoop2.7 /usr/local/spark;
echo export PATH="$PATH:/usr/local/spark/bin" > ~/._bashrc;
echo export SPARK_HOME="$PATH:/usr/local/spark" >> ~/._bashrc;
sudo cp /usr/local/spark/conf/spark-env.sh.template /usr/local/spark/conf/spark-env.sh;
sudo cp /usr/local/spark/conf/slaves.template /usr/local/spark/conf/slaves;

pip3 install -r /local/setup/requirements.txt;

ips=($(ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}'))
for ip in "${ips[@]}"
do
    if [[ $ip == *"10."* ]]; then
        echo export LOCAL_IP=$ip >> ~/._bashrc;
        LOCAL_IP=$ip
    fi
done

# sudo /usr/local/bin/jupyter contrib nbextension install --system ;
# sudo /usr/local/bin/jupyter nbextensions_configurator enable --system ;
# sudo /usr/local/bin/jupyter nbextension enable code_prettify/code_prettify --system ;
# sudo /usr/local/bin/jupyter nbextension enable execute_time/ExecuteTime --system ;
# sudo /usr/local/bin/jupyter nbextension enable collapsible_headings/main --system ;
# sudo /usr/local/bin/jupyter nbextension enable freeze/main --system ;
# sudo /usr/local/bin/jupyter nbextension enable spellchecker/main --system ;

master_ip=$(gethostip -d master);
echo "export SPARK_MASTER_HOST=$master_ip" | sudo tee -a /usr/local/spark/conf/spark-env.sh;
echo "export SPARK_LOCAL_IP=$LOCAL_IP" | sudo tee -a /usr/local/spark/conf/spark-env.sh;
echo "export PYSPARK_PYTHON=python3.6" | sudo tee -a /usr/local/spark/conf/spark-env.sh;

# echo "worker-0" | sudo tee /usr/local/spark/conf/slaves;

cp ~/._bashrc /local/.bashrc

if [ "$duty" = "m" ]; then
	sudo bash /usr/local/spark/sbin/start-master.sh
	sudo nohup socat TCP-LISTEN:8081,fork TCP:127.0.0.1:8080 > /dev/null 2>&1 &
	sudo nohup socat TCP-LISTEN:4041,fork TCP:127.0.0.1:4040 > /dev/null 2>&1 &

elif [ "$duty" = "s" ]; then
	sudo bash /usr/local/spark/sbin/start-slave.sh $master_ip:7077
	sudo nohup socat TCP-LISTEN:8082,fork TCP:127.0.0.1:8081 > /dev/null 2>&1 &	
fi








