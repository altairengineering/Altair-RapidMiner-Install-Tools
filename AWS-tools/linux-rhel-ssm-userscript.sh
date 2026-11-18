#!/bin/bash -l
sudo dnf update –y
sudo dnf upgrade –y
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm || sudo dnf install –y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
echo "Agent installed"


#install awscli
sudo dnf install --assumeyes unzip
curl -o /tmp/install.sh -fsSL https://awscli.amazonaws.com/v2/install.sh
sudo bash /tmp/install.sh --system 

#crowdstrike
sudo /usr/local/bin/aws s3 cp s3://cso-edr-agent-installers/Linux/64bit/falcon-sensor-7.35.0-18803.amzn2023.x86_64.rpm /tmp/crowdstrike_installer.rpm --region us-east-1
sudo dnf install --assumeyes /tmp/crowdstrike_installer.rpm
TOKEN=$(/usr/local/bin/aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:887563472458:secret:crowdstrike/install_token-61v6Nq --region us-east-1 --query SecretString --output text | jq -r '.CrowdStrike_Install_Token')
CID=$(/usr/local/bin/aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:887563472458:secret:crowdstrike/cid-iAuBMG --region us-east-1 --query SecretString --output text | jq -r '.CrowdStrike_CID')
sudo /opt/CrowdStrike/falconctl -s --cid=$CID --provisioning-token=$TOKEN
sudo systemctl start falcon-sensor
sleep 120
AGENT_ID=$(sudo /opt/CrowdStrike/falconctl -g --aid)
touch /home/"${TARGET_USER}"/AGENT_ID.txt
echo "${AGENT_ID}" | sudo tee -a /home/"${TARGET_USER}"/AGENT_ID.txt


exit 0
