#!/bin/bash
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
sudo dnf config-manager --set-enabled crb
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm || sudo dnf install –y amazon-ssm-agent
sudo dnf update -y
sudo dnf install firewalld -y
sudo systemctl enable --now firewalld
sudo dnf install --assumeyes unzip groff less btop

sudo dnf groupinstall -y 'Server with GUI'
sudo dnf groupinstall -y GNOME
#sudo sed -i '/^\[daemon\]/a WaylandEnable=false' /etc/gdm/custom.conf
sudo systemctl set-default graphical.target

#install awscli
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | sudo bash -s -- --system

#install eksctl
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
sudo tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && sudo rm eksctl_$PLATFORM.tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin && sudo rm /tmp/eksctl

#install wayvnc
sudo dnf install -y wayvnc
sudo systemctl isolate multi-user.target && sudo systemctl isolate graphical.target


#configure firewall rules
if (which firewall-offline-cmd); then
  sudo systemctl stop firewalld
  sudo firewall-offline-cmd --add-port 5901/tcp
  sudo firewall-offline-cmd --add-port 5901/udp
  sudo firewall-offline-cmd --add-port 8443/tcp
  sudo firewall-offline-cmd --add-port 8443/udp
  sudo firewall-offline-cmd --add-port 22/tcp
  sudo firewall-offline-cmd --add-port 80/udp
  sudo firewall-offline-cmd --add-port 80/tcp
  sudo firewall-offline-cmd --add-port 443/udp
  sudo firewall-offline-cmd --add-port 443/tcp
  sudo firewall-offline-cmd --add-port 53/udp
  sudo firewall-offline-cmd --add-port 53/tcp
  sudo systemctl start firewalld
fi


systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
exit 0
