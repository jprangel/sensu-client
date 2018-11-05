
echo '[sensu]
name=sensu
baseurl=https://sensu.global.ssl.fastly.net/yum/$releasever/$basearch/
gpgkey=https://repositories.sensuapp.org/yum/pubkey.gpg
gpgcheck=1
enabled=1' | sudo tee /etc/yum.repos.d/sensu.repo

sudo yum install sensu

sudo chkconfig sensu-client on

sudo cp conf/config.json /etc/sensu/conf.d/
sudo cp conf/client.json /etc/sensu/conf.d/
HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/hostname)
LOCAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
sed s/HOST_NAME/$HOSTNAME/g /etc/sensu/conf.d/client.json -i
sed s/HOST_IP/$LOCAL_IP/g /etc/sensu/conf.d/client.json -i
sudo service sensu-client restart

