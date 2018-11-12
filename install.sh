
ENV_VERSION_YUM=$(cat /etc/yum.repos.d/epel.repo | grep 'gpgkey=file' | head -n 1 | cut -d- -f 6)

echo "Configure Sensu repo"
sudo cp -arf sensu.repo /etc/yum.repos.d/
sudo sed s/VERSION_YUM/$ENV_VERSION_YUM/g /etc/yum.repos.d/sensu.repo -i

echo "Install Sensu"
sudo yum install -y sensu

echo "Enable Sensu Service"
sudo chkconfig sensu-client on

echo "Update the configuration"
sudo cp conf/config.json /etc/sensu/conf.d/
sudo cp conf/client.json /etc/sensu/conf.d/
HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/hostname)
LOCAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
sudo sed s/HOST_NAME/$HOSTNAME/g /etc/sensu/conf.d/client.json -i
sudo sed s/HOST_IP/$LOCAL_IP/g /etc/sensu/conf.d/client.json -i

echo "Restart Sensu service"
sudo service sensu-client restart
