#!/bin/bash
# deploy as userscript
# Amazon Linux 2023 docker install script by anthony kiehl
dnf update -y
dnf upgrade -y
dnf install -y spal-release
sudo dnf -y install dnf-plugins-core
dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc
dnf install -y wget vim unzip openssl certbot git unzip openssl haveged net-tools
systemctl start certbot-renew.timer
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf update -y
dnf install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
systemctl enable docker
systemctl start haveged
systemctl enable haveged
usermod -aG docker ssm-user
usermod -aG docker ec2-user
docker container run hello-world
docker compose version
exit 0
