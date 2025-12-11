#!/bin/bash

# Ubuntu docker install script by anthony kiehl

# Need to whitelist these URLs for port 80 and/or 443:
# api.snapcraft.io
# archive.ubuntu.com
# changelogs.ubuntu.com
# download.docker.com
# github.com
# objects.githubusercontent.com
# registry-1.docker.io
# auth.docker.io
# production.cloudflare.docker.com
# docs.rapidminer.com
# platform.rapidminer.com
#dockercomposeversion="v2.23.0"
#replaced docker-compose with docker compose

[ $# -eq 0 ] && { echo "Usage: $0 username"; exit 1; }

[ `whoami` = root ] || { echo 'you must be root'; exit 1; }

wget -q --tries=10 --timeout=20 --spider -O - http://google.com > /dev/null
if [[ $? -eq 0 ]]; then
        echo "Internet connectivity detected."
else
        echo "This script requires internet connectivity to function"
        echo "If you need to set proxy, that could be an issue"
        exit 1
fi

DEBIAN_FRONTEND=noninteractive apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
{ #try
DEBIAN_FRONTEND=noninteractive apt-get remove -y docker docker.io containerd runc
DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
DEBIAN_FRONTEND=noninteractive apt-get install -y unzip curl wget vim ca-certificates gnupg lsb-release haveged openssl certbot
curl -kfsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
DEBIAN_FRONTEND=noninteractive apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io
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
