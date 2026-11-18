#!/bin/bash -l

#install ssm agent
sudo dnf install --assumeyes https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm || sudo dnf install –y amazon-ssm-agent
sudo systemctl enable --now amazon-ssm-agent


#install awscli
sudo dnf install --assumeyes unzip
curl -o /tmp/install.sh -fsSL https://awscli.amazonaws.com/v2/install.sh
sudo bash /tmp/install.sh --system 

#install eksctl
PLATFORM=$(uname -s)_amd64
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"
sudo tar -xzf eksctl_"${PLATFORM}".tar.gz -C /tmp && sudo rm eksctl_"${PLATFORM}".tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin && sudo rm /tmp/eksctl


#install expanded repos and updatee
dnf install --assumeyes https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
sudo dnf install firewalld --assumeyes
sudo systemctl enable --now firewalld
sudo dnf install --assumeyes groff less btop gnutls-utils certbot git vim kubectl haveged
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
sudo firewall-offline-cmd --add-port 5903/tcp
sudo firewall-offline-cmd --add-port 5903/tcp
sudo systemctl start firewalld

#install VNC server
touch /home/ssm-user/README.txt
  sudo dnf install --assumeyes tigervnc-server
  sudo cp /usr/lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:3.service
  echo ':3=ssm-user' >> /etc/tigervnc/vncserver.users
  mkdir -p /home/ssm-user/.vnc
  touch /home/ssm-user/.vnc/config
  sudo tee -a /home/ssm-user/.vnc/config > /dev/null << 'EOF'
session=gnome
securitytypes=vncauth,tlsvnc
geometry=1440x900
EOF

  sudo systemctl enable --now vncserver@:3.service
  echo "Please run command: vncpasswd" > /home/ssm-user/README.txt

#crowdstrike
sudo /usr/local/bin/aws s3 cp s3://cso-edr-agent-installers/Linux/64bit/falcon-sensor-7.35.0-18803.amzn2023.x86_64.rpm crowdstrike_installer.rpm --region us-east-1
sudo yum install crowdstrike_installer.rpm
TOKEN=$(/usr/local/bin/aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:887563472458:secret:crowdstrike/install_token-61v6Nq --region us-east-1 --query SecretString --output text | jq -r '.CrowdStrike_Install_Token')
CID=$(/usr/local/bin/aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:887563472458:secret:crowdstrike/cid-iAuBMG --region us-east-1 --query SecretString --output text | jq -r '.CrowdStrike_CID')
sudo /opt/CrowdStrike/falconctl -s --cid=$CID --provisioning-token=$TOKEN
sudo systemctl start falcon-sensor
sleep 120
AGENT_ID=$(sudo /opt/CrowdStrike/falconctl -g --aid)
touch /home/"${TARGET_USER}"/AGENT_ID.txt
echo "${AGENT_ID}" | sudo tee -a /home/"${TARGET_USER}"/AGENT_ID.txt


exit 0
