#!/usr/bin/env bash
# Crowdstrike DNF-based Linux system install script
TOKEN=""
CID=""

#check for root
[ "$(whoami)" = root ] || { echo 'You must first become root with sudo su - '; exit 1; }

#remove sentinel one
{ #try


#install falcon sensor
if [ $(ps -e | grep -ic "falcon-sensor" -gt 0); then
  sudo aws s3 cp s3://cso-edr-agent-installers/Linux/64bit/falcon-sensor-7.35.0-18803.amzn2023.x86_64.rpm crowdstrike_installer.rpm --region us-east-1
  sudo yum install crowdstrike_installer.rpm
  TOKEN=$(aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:887563472458:secret:crowdstrike/install_token-61v6Nq --region us-east-1 --query SecretString --output text | jq -r '.CrowdStrike_Install_Token')
  CID=$(aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:887563472458:secret:crowdstrike/cid-iAuBMG --region us-east-1 --query SecretString --output text | jq -r '.CrowdStrike_CID')
  sudo /opt/CrowdStrike/falconctl -s --cid=$CID --provisioning-token=$TOKEN
  sudo systemctl start falcon-sensor
else
  echo "Falcon-sensor already installed, skipping."
fi
