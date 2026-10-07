#!/bin/bash
# Amazon Linux 2023 docker install script by anthony kiehl
sudo dnf update -y
sudo dnf upgrade -y
sudo dnf install -y spal-release
sudo dnf install -y wget vim unzip openssl certbot git unzip openssl haveged net-tools
sudo systemctl start certbot-renew.timer
sudo dnf update -y
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl start haveged
sudo systemctl enable haveged
sudo usermod -a -G docker ssm-user
sudo usermod -a -G docker ec2-user
exit 0
