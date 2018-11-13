#/bin/bash

ENV_VERSION_YUM=$(cat /etc/yum.repos.d/epel.repo | grep 'gpgkey=file' | head -n 1 | cut -d- -f 6)

function install()
{
	echo ">> Configure Sensu repo"
	sudo cp -arf sensu.repo /etc/yum.repos.d/
	sudo sed s/VERSION_YUM/$ENV_VERSION_YUM/g /etc/yum.repos.d/sensu.repo -i

	echo ">> Install Sensu"
	sudo yum install -q -y sensu

	echo ">> Enable Sensu Service"
	sudo chkconfig sensu-client on

	echo ">> Copying the configuration"
	sudo cp -arf  conf/config.json /etc/sensu/conf.d/
	sudo cp -arf conf/client.json /etc/sensu/conf.d/

	echo ">> Updating IP"
	LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
	sudo sed s/HOST_IP/$LOCAL_IP/g /etc/sensu/conf.d/client.json -i

}

function install_docker()
{
	 echo ">> Configuring docker client"
	 HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname)
         sudo sed s/HOST_NAME/$HOSTNAME/g /etc/sensu/conf.d/client.json -i
         echo ">> Restart Sensu service"
         sudo service sensu-client restart
}

function install_ec2()
{
	echo ">> Configuring ec2 client"
	HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/security-groups/)
	sudo sed s/HOST_NAME/$HOSTNAME/g /etc/sensu/conf.d/client.json -i
	echo ">> Restart Sensu service"
	sudo service sensu-client restart
}


function server_type()
{

install

  if [ "$1" == "docker" ];
  then
     install_docker
  else
     install_ec2
  fi
}

function usage()
{
	echo "usage: install_client_sensu.sh [-t --type [ docker| ec2 ] | [-h]]"
}

case $1 in
     -t | --type )
     server_type $2
     ;;
     -h | --help )
     usage
     exit
     ;;
     * )
     usage
     exit 1
esac
