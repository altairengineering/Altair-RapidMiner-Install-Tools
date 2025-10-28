#!/bin/bash

# Arch docker install script by anthony kiehl

#dockercomposeversion="v2.23.0"
#replaced docker-compose with docker compose

[ $# -eq 0 ] && { echo "Usage: $0 username"; exit 1; }

[ `whoami` = root ] || { echo 'you must be root'; exit 1; }

pacman -Sy --noconfirm
pacman -Syu --noconfirm
{ #try
pacman -S --noconfirm curl wget vim unzip
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sed -i 's/rhel/centos/g' /etc/yum.repos.d/docker-ce.repo
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf update -y
dnf install -y haveged
dnf install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
systemctl enable docker
systemctl start haveged
systemctl enable haveged
usermod -aG docker $1
#curl -kL "https://github.com/docker/compose/releases/download/$dockercomposeversion/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
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
