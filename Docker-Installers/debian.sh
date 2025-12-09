#!/bin/bash

#Debian docker install script by anthony kiehl

# Need to whitelist these URLs for port 80 and/or 443:
# security.debian.org
# ftp.debian.org
# debian.org
# api.snapcraft.io
# download.docker.com
# github.com
# objects.githubusercontent.com
# registry-1.docker.io
# auth.docker.io
# production.cloudflare.docker.com
# docs.rapidminer.com
# platform.rapidminer.com

[ $# -eq 0 ] && { echo "Usage: $0 username"; exit 1; }

[ `whoami` = root ] || { echo 'you must be root'; exit 1; }

echo $PATH | grep sbin
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo "Correct execution permissions \"su -\""
else
  echo "Must be run specifically as \"su -\""
  exit 1
fi

wget -q --tries=10 --timeout=20 --spider -O - http://google.com > /dev/null
if [[ $? -eq 0 ]]; then
        echo "Internet connectivity detected."
else
        echo "This script requires internet connectivity to function"
        echo "If you need to set proxy, that could be an issue"
        exit 1
fi
sed -i '/cdrom/d' /etc/apt/sources.list
DEBIAN_FRONTEND=noninteractive apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
{ #try
DEBIAN_FRONTEND=noninteractive apt-get remove -y docker docker.io containerd runc
DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
DEBIAN_FRONTEND=noninteractive apt-get install -y unzip curl wget vim ca-certificates gnupg lsb-release haveged openssl
curl -kfsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
DEBIAN_FRONTEND=noninteractive apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io
echo "set nocompatible" > /root/.exrc
echo "set nocompatible" > /home/$1/.exrc
systemctl start docker
systemctl enable docker
systemctl start haveged
systemctl enable haveged
usermod -aG docker $1
docker container run hello-world
docker compose version
} || { #catch
echo 'one of the components failed'
exit 1
}


echo 'Docker and Docker compose installed successfully.'
echo 'YOU MUST RESTART THIS SYSTEM BEFORE USING DOCKER.'
echo 'DEBIAN REQUIRES REBOOT FOR THE NEW DOCKER GROUP.'
exit 0
