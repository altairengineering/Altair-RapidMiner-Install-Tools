#!/bin/bash
# deploy as userscript
# Amazon Linux 2023 docker install script by anthony kiehl
sudo dnf update -y
sudo dnf upgrade -y
sudo dnf install -y spal-release
sudo sudo dnf -y install dnf-plugins-core
sudo dnf install -y wget vim unzip openssl certbot git unzip openssl haveged net-tools
sudo systemctl start certbot-renew.timer
sudo dnf update -y
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl start haveged
sudo systemctl enable haveged
sudo usermod -aG docker ssm-user
sudo usermod -aG docker ec2-user
exit 0
