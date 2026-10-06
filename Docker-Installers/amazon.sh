#!/bin/bash

# Amazon Linux 2023 docker install script by anthony kiehl

[ $# -eq 0 ] && { echo "Usage: $0 username"; exit 1; }

[ `whoami` = root ] || { echo 'you must be root'; exit 1; }
curl http://google.com > /dev/null
if [[ $? -eq 0 ]]; then
        echo "Internet connectivity detected."
else
        echo "This script requires internet connectivity to function"
        echo "If you need to set proxy, that could be an issue"
        read -n1 -r -p "It is strongly advisable to only run this script if the previous test passed!  Press any key to continue, or Cntl-C to exit without installing"
fi

dnf update -y
dnf upgrade -y
{ #try
dnf install spal-release
dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc
dnf install -y curl wget vim unzip openssl certbot git unzip openssl haveged net-tools
dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.reposed -i 's/rhel/centos/g' /etc/yum.repos.d/docker-ce.repo
dnf update -y
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
