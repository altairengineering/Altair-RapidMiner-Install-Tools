#!/bin/bash
#install software
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
sudo crb enable
sudo dnf upgrade -y
sudo dnf install firewalld -y
sudo dnf install --assumeyes unzip groff less btop gnutls-utils certbot git

#install ssm agent
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm || sudo dnf install –y amazon-ssm-agent


#install awscli
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | sudo bash -s -- --system

#install eksctl
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
sudo tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && sudo rm eksctl_$PLATFORM.tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin && sudo rm /tmp/eksctl

#install gnome
sudo dnf groupinstall -y 'Server with GUI'
sudo dnf groupinstall -y GNOME
sudo dnf install -y wayvnc
sudo systemctl set-default graphical.target


#install wayvnc
mkdir -p /home/ssm-user/.config/wayvnc
cat >> /home/ssm-user/.config/wayvnc/config << 'END'
enable_auth=true
password=rapidminer
relax_encryption=true
allow_broken_crypto=true
END

sudo cat >> /etc/systemd/system/wayvnc.service << 'END'
[Unit]
Description=WayVNC service
After=network.target
After=systemd-user-sessions.service
After=network-online.target

[Service]
User=ssm-user
ExecStart='/usr/bin/wayvnc 0.0.0.0'


[Install]
WantedBy=multi-user.target
END




#start services
sudo systemctl enable --now amazon-ssm-agent
sudo systemctl enable --now wayvnc
sudo systemctl enable --now firewalld


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
