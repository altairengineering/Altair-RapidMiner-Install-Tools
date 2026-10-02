#!/bin/bash
#install software
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
sudo dnf update -y
sudo dnf install firewalld -y
sudo systemctl enable --now firewalld
sudo dnf install --assumeyes unzip groff less btop gnutls-utils certbot git

#install ssm agent
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm || sudo dnf install –y amazon-ssm-agent


#install gnome
sudo dnf groupinstall -y 'Server with GUI'
sudo dnf groupinstall -y GNOME
sudo sed -i '/^\[daemon\]/a WaylandEnable=false' /etc/gdm/custom.conf
sudo systemctl set-default graphical.target

#install awscli
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | sudo bash -s -- --system

#install eksctl
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
sudo tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && sudo rm eksctl_$PLATFORM.tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin && sudo rm /tmp/eksctl

#install DCV
cd /tmp
sudo rpm --import https://d1uj6qtbmh3dt5.cloudfront.net/NICE-GPG-KEY
OS_VERSION=$(. /etc/os-release;echo $VERSION_ID | sed -e 's/\..*//g')
curl -L -O https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-el$OS_VERSION-$(arch).tgz
tar -xvzf nice-dcv-el$OS_VERSION-$(arch).tgz && cd nice-dcv-*-el$OS_VERSION-$(arch)
sudo dnf install -y ./nice-dcv-server-*.rpm
sudo dnf install -y ./nice-dcv-web-viewer-*.rpm
sudo dnf install -y ./nice-xdcv-*.rpm
sudo systemctl enable dcvserver
sudo systemctl enable --now xdcv-console-update.service
sudo systemctl enable xdcv-console.path
USER="ec2-user"
sudo sed -i "/^\[session-management\/automatic-console-session/a owner=\"$USER\"\nstorage-root=\"%home%\"" /etc/dcv/dcv.conf
sudo sed -i "s/^#create-session/create-session/g" /etc/dcv/dcv.conf
sudo usermod -a -G sys dcv



#configure firewall rules
if (which firewall-offline-cmd); then
  sudo systemctl stop firewalld
  sudo firewall-offline-cmd --add-port 5901/tcp
  sudo firewall-offline-cmd --add-port 5901/udp
  sudo firewall-offline-cmd --add-port 3389/udp
  sudo firewall-offline-cmd --add-port 3389/tcp
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
sudo systemctl isolate multi-user.target && sudo systemctl isolate graphical.target
sudo systemctl stop dcvserver && sudo systemctl start dcvserver
exit 0
