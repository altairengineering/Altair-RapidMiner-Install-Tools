#!/bin/bash
#
# Rocky docker install script by anthony kiehl
#
# Need to whitelist these URLs for port 80 and/or 443:
#https://hub.docker.com/
#https://download.docker.com/
#https://github.com/docker/compose/releases/
#https://www.anaconda.com/
#https://mirrors.rockylinux.org
#https://objects.githubusercontent.com
#https://dl.rockylinux.org/
#http://mirror.chpc.utah.edu
#https://mirror.usi.edu
#https://github.com
#http://dl.rockylinux.org/
#https://mirrors.fedoraproject.org
#https://*.docker.io
#104.18.124.25:443
# docs.rapidminer.com
# platform.rapidminer.com
#
#dockercomposeversion="v2.23.0"
#replaced docker-compose with docker compose

[ $# -eq 0 ] && { echo "Usage: $0 username"; exit 1; }

[ `whoami` = root ] || { echo 'you must be root'; exit 1; }
curl -I http://google.com > /dev/null
if [[ $? -eq 0 ]]; then
        echo "Internet connectivity detected."
else
        echo "This script requires internet connectivity to function"
        echo "If you need to set proxy, that could be an issue"
        exit 1
fi

dnf update -y
dnf upgrade -y
{ #try
dnf remove -y docker*
dnf install -y epel-release
dnf install -y dnf-utils curl wget vim unzip openssl certbot
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf update -y --allowerasing
dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --allowerasing
dnf install -y haveged --allowerasing
systemctl start docker
systemctl enable docker
systemctl start haveged
systemctl enable haveged
usermod -aG docker $1
#curl -L "https://github.com/docker/compose/releases/download/$dockercomposeversion/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#chmod +x /usr/local/bin/docker-compose
#ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker container run hello-world
#docker-compose --version
docker compose version
} || { #catch
echo 'one of the components failed'
exit 1
}


echo 'Docker and Docker compose installed successfully.'
echo 'YOU MUST RESTART THIS SYSTEM BEFORE USING DOCKER.'
exit 0
