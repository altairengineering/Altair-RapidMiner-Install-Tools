#!/bin/bash

#install ssm agent
sudo dnf install --assumeyes https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm || sudo dnf install –y amazon-ssm-agent
sudo systemctl enable --now amazon-ssm-agent


#install awscli
sudo dnf install --assumeyes unzip
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
sudo systemctl stop firewalld
sudo firewall-offline-cmd --add-port 22/tcp
sudo firewall-offline-cmd --add-port 80/udp
sudo firewall-offline-cmd --add-port 80/tcp
sudo firewall-offline-cmd --add-port 443/udp
sudo firewall-offline-cmd --add-port 443/tcp
sudo firewall-offline-cmd --add-port 53/udp
sudo firewall-offline-cmd --add-port 53/tcp
sudo systemctl start firewalld

#install VNC server
RHELTYPE=$(cat /etc/os-release  | grep VERSION_ID | cut -d '"' -f 2)
if [ "${RHELTYPE}" -lt 10 ]; then
  sudo dnf install --assumeyes tigervnc-server
  sudo cp /usr/lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:3.service
  echo ':3=ssm-user' >> /etc/tigervnc/vncserver.users
  echo 'session=gnome' >> /home/ssm-user/.vnc/config
  echo 'securitytypes=vncauth,tlsvnc' >> /home/ssm-user/.vnc/config
  echo 'geometry=1024x768' >> /home/ssm-user/.vnc/config
  sudo systemctl enable --now vncserver@:3.service
  sudo systemctl stop firewalld
  sudo firewall-offline-cmd --add-port 5902/tcp
  sudo firewall-offline-cmd --add-port 5902/udp
  sudo systemctl start firewalld
  echo "Please run command: vncpasswd" > /home/ssm-user/README.txt
else
  sudo dnf install --assumeyes freerdp
  sudo systemctl stop firewalld
  sudo firewall-offline-cmd --add-port 3389/udp
  sudo firewall-offline-cmd --add-port 3389/tcp
  sudo systemctl start firewalld
  sudo systemctl enable --now gdm
  dbus-launch gsettings set org.gnome.login-screen enable-fingerprint-authentication false
  echo "Please run command: grdctl --system rdp set-credentials" > /home/ssm-user/README.txt
  sudo cat >> /etc/gdm/custom.conf << 'END'
[daemon]
TimedLoginEnable=true
TimedLogin=ssm-user
TimedLoginDelay=1
END
  sudo cat >> /var/lib/AccountsService/users/ssm-user << 'END'
[User]
XSession=gnome-xorg  
END
  sudo systemctl edit --stdin gnome-remote-desktop.service << 'EOF'
[Unit]
Description=GNOME Remote Desktop
After=gdm.service

[Service]
Type=dbus
User=gnome-remote-desktop
BusName=org.gnome.RemoteDesktop
ExecStart=/usr/libexec/gnome-remote-desktop-daemon --system
Restart=on-failure

[Install]
WantedBy=graphical.target
EOF
  sudo systemctl enable --now gnome-remote-desktop.service
fi

exit 0
