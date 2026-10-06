#!/bin/bash
# deploy as userscript
# Amazon Linux 2023 docker install script by anthony kiehl
dnf update -y
dnf upgrade -y
dnf install -y spal-release
dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc
dnf install -y curl wget vim unzip openssl certbot git unzip openssl haveged net-tools
dnf config-manager -y addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.reposed -i 's/rhel/centos/g' /etc/yum.repos.d/docker-ce.repo
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
