#!/bin/bash
#config
TARGET_USER=ssm-user
PLATFORM=$(uname -s)_amd64

#install ssm agent
sudo dnf install --assumeyes https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm || sudo dnf install –y amazon-ssm-agent
sudo systemctl enable --now amazon-ssm-agent


#install awscli
sudo dnf install --assumeyes unzip
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | sudo bash -s -- --system


#install eksctl
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"
sudo tar -xzf eksctl_"${PLATFORM}".tar.gz -C /tmp && sudo rm eksctl_"${PLATFORM}".tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin && sudo rm /tmp/eksctl

#install expanded repos and updatee
sudo dnf install --assumeyes https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
sudo dnf update --asumeyes
sudo dnf upgrade --assumeyes


#install firewall
sudo dnf install firewalld --assumeyes
sudo systemctl enable --now firewalld
sudo systemctl stop firewalld
sudo firewall-offline-cmd --add-port 22/tcp
sudo firewall-offline-cmd --add-port 80/udp
sudo firewall-offline-cmd --add-port 80/tcp
sudo firewall-offline-cmd --add-port 443/udp
sudo firewall-offline-cmd --add-port 443/tcp
sudo firewall-offline-cmd --add-port 53/udp
sudo firewall-offline-cmd --add-port 53/tcp
sudo systemctl start firewalld

#install tools
sudo dnf install --assumeyes groff less btop gnutls-utils certbot git vim

#install gnome
sudo dnf groupinstall --assumeyes 'Server with GUI'
sudo systemctl set-default graphical.target

#install RDP server
sudo dnf install --assumeyes freerdp
sudo systemctl stop firewalld
sudo firewall-offline-cmd --add-port 3389/udp
sudo firewall-offline-cmd --add-port 3389/tcp
sudo systemctl start firewalld
sudo systemctl enable --now gdm
sudo dbus-launch gsettings set org.gnome.login-screen enable-fingerprint-authentication false

#configure gdm
sudo tee -a /etc/gdm/custom.conf > /dev/null << 'EOF'
[daemon]
TimedLoginEnable=true 
TimedLogin=${TARGET_USER}
TimedLoginDelay=1
EOF
#

#configure user
sudo touch /var/lib/AccountsService/users/"${TARGET_USER}"
sudo tee -a /var/lib/AccountsService/users/"${TARGET_USER}" > /dev/null << 'EOF'
[User]
XSession=gnome-xorg
EOF
#

#configure systemd
sudo mkdir -p /etc/systemd/system/gnome-remote-desktop.service.d
sudo touch /etc/systemd/system/gnome-remote-desktop.service.d/override.conf
sudo tee -a /etc/systemd/system/gnome-remote-desktop.service.d/override.conf > /dev/null << 'EOF'
[Unit]
After=gdm.service
EOF
#

sudo systemctl enable --now gnome-remote-desktop.service


#documentation
touch /home/"${TARGET_USER}"/README.txt
echo "Please run command: grdctl --system rdp set-credentials" | sudo tee -a /home/"${TARGET_USER}"/README.txt
exit 0
