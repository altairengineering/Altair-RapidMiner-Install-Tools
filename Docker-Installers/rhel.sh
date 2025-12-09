#!/bin/bash

# RHEL docker install script by anthony kiehl

# Need to whitelist these URLs for port 80 and/or 443:
# subscription.rhsm.redhat.com
# cdn.redhat.com
# download.docker.com
# dl.fedoraproject.org
# mirrors.fedoraproject.org
# mirror.fcix.net
# mirror.lshiy.com
# epel.mirror.constant.com
# github.com
# objects.githubusercontent.com
# registry-1.docker.io
# auth.docker.io
# production.cloudflare.docker
# docs.rapidminer.com
# platform.rapidminer.com
#dockercomposeversion="v2.23.0"
#replaced docker-compose with docker compose

[ $# -eq 0 ] && { echo "Usage: $0 username"; exit 1; }

[ `whoami` = root ] || { echo 'you must be root'; exit 1; }
curl http://google.com > /dev/null
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
dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc
dnf install -y curl wget vim unzip openssl
#yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
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
