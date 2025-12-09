#!/bin/bash

# SLES docker install script by anthony kiehl

# Need to whitelist these URLs for port 80 and/or 443:
# download.docker.com
# github.com
# objects.githubusercontent.com
# registry-1.docker.io
# auth.docker.io
# production.cloudflare.docker.com
# docs.rapidminer.com
# platform.rapidminer.com
#
#replaced docker-compose with docker compose
docker_Version="v2.29.6"

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

zypper -n update
zypper -n patch
{ #try
#clean up existing docker installs
zypper -n remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  runc
zypper -n clean
#install dependancies, entropy generator, and tools
zypper -n install unzip curl wget vim ca-certificates gnupg lsb-release haveged openssl
#zypper -n addrepo https://download.docker.com/linux/sles/docker-ce.repo
zypper -n update
#install docker ce for suse
suseconnect -d -p sle-module-basesystem/15.6/x86_64
suseconnect -p sle-module-containers/15.6/x86_64
zypper -n install docker docker-bash-completion docker-rootless-extras git-core lvm2
systemctl start docker
systemctl enable docker
systemctl start haveged
systemctl enable haveged
#the arguement is the username of the rapidminer linux user
usermod -aG rapidminer rapidminer
setfacl -m "user:$1:rw" /var/run/docker.sock
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/$docker_Version/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
docker container run hello-world
docker compose version
} || { #catch
echo 'one of the components failed'
exit 1
}


echo 'Docker and Docker compose installed successfully.'
echo 'YOU MUST RESTART THIS SYSTEM BEFORE USING DOCKER.'

exit 0

