#!/bin/bash

#install ssm agent
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm || sudo dnf install –y amazon-ssm-agent
sudo systemctl enable --now amazon-ssm-agent


#install awscli
sudo dnf install -y unzip
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | sudo bash -s -- --system


#install eksctl
PLATFORM=$(uname -s)_amd64
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
sudo tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && sudo rm eksctl_$PLATFORM.tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin && sudo rm /tmp/eksctl

#install expanded repos and updatee
sudo dnf install --assumeyes https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
sudo dnf install firewalld --assumeyes
sudo systemctl enable --now firewalld
sudo dnf install --assumeyes groff less btop gnutls-utils certbot git vim
sudo dnf upgrade --assumeyes



#install gnome
sudo dnf groupinstall --assumeyes 'Server with GUI'
sudo systemctl set-default graphical.target



#configure firewall rules
if (which firewall-offline-cmd); then
  sudo systemctl stop firewalld
  sudo firewall-offline-cmd --add-port 5900/tcp
  sudo firewall-offline-cmd --add-port 5900/udp
  sudo firewall-offline-cmd --add-port 5901/tcp
  sudo firewall-offline-cmd --add-port 5901/udp
  sudo firewall-offline-cmd --add-port 3389/udp
  sudo firewall-offline-cmd --add-port 3389/tcp
  sudo firewall-offline-cmd --add-port 22/tcp
  sudo firewall-offline-cmd --add-port 80/udp
  sudo firewall-offline-cmd --add-port 80/tcp
  sudo firewall-offline-cmd --add-port 443/udp
  sudo firewall-offline-cmd --add-port 443/tcp
  sudo firewall-offline-cmd --add-port 53/udp
  sudo firewall-offline-cmd --add-port 53/tcp
  sudo systemctl start firewalld
fi
exit 0
