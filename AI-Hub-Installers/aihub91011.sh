#!/bin/bash
#config
hubversion="9.10.11"
currentcomposeversion="v2.18.1"
#main
[ `whoami` = root ] || { echo 'you must run with sudo'; exit 1; }

#promts:
echo \n
echo "AI-Hub install helper"
echo "ALTAIR - Anthony Kiehl"
echo "Version 1.4b - version 9.10.11 10/3/23"
echo "Version 1.4 - version 9.10.14 6/14/23"
echo "Version 1.3 - Removed all go"
echo "Version 1.2 - Added go licensing"
echo "Version 1.1 - Added version checking and bugfixes 11/3/22"
echo "Version 1.0 - Initial Release 9/20/22"
echo "Special thanks to Sharan G."
echo "AI-hub version $hubversion"
echo "======================================================================"
sleep 1
echo "Detecting Docker and Docker-Compose versions"
sleep 1
dockerver=`docker --version | cut -d " " -f 3 | sed 's/,$//'`
echo "Detected Docker $dockerver"
sleep 1

composever=`docker compose version | cut -d " " -f 4 | sed 's/,$//'`
echo "Detected Compose $composever"
sleep 1

echo "If you want to use the configuration file for automated installation choices, press Cntl-C.  Then use the absolute or relative path to the configuration file, after filling it out."
read -n1 -r -p "Press any key to continue, or Cntl-C to exit without installing"

if [ -z "$1" ]; then


 #user name
 echo "Please enter the exact name of the linux user who is not root and for whom docker has been enabled with wheel access:" 
 read aihubuser

 if [ -d /home/$aihubuser/ ];
 then
	echo "Found $aihublin"
 else	
	echo "$aihubuser is not correct or does not have a home folder"
	exit 1
 fi


#hostname or ip
 echo 'Please enter the complete FQDN of the server.  Alternatively, you may use IP address but never localhost:' 
 read aihubhostname


#timezone
 echo "Please enter a timezone.  Example: America/New_York"
 read linuxtimezone

#enter a passphrase twice
 echo 'Please carefully enter the password to use for the admin account on ai-hub:' 
 read -s aihubpasswordfirst
 echo "Please re-enter password:" 
 read -s aihubpasswordsecond
 if [ "$aihubpasswordfirst" == "$aihubpasswordsecond" ]; then
	echo "Password recorded"
	aihubpassword=$aihubpasswordfirst
#	echo "DEBUG: $aihubpassword"
 else
	echo "Passwords did not match"
	exit 1
 fi


#enter valid license
echo "You must acquire a valid RM license to continue, talk to your sales rep"
 echo "Please paste your ai-hub license:" 
 read aihublicense


else
#here we read the config file

 source $1

fi


#install ai-hub
#download ai-hub and echo the version

echo "Downloading and installing AI-Hub"
sleep 1
echo "Downloading AI-Hub version $hubversion"
sleep 1
echo "Downloading $hubversion from https://docs.rapidminer.com/assets/download/hub/rapidminer-ai-hub-$hubversion-docker-compose-template-prod.zip"
sleep 1
wget -P /home/$aihubuser/ https://docs.rapidminer.com/assets/download/hub/rapidminer-ai-hub-$hubversion-docker-compose-template-prod.zip
sleep 1
#unzip
echo "Extracting data"
cd /home/$aihubuser/ && unzip /home/$aihubuser/rapidminer-ai-hub-$hubversion-docker-compose-template-prod.zip
sleep 1
ls /home/$aihubuser/prod
echo "Files staged in prod folder"
#sed commands
sleep 1

sed -i "s%TZ=UTC%TZ=$linuxtimezone%g" /home/$aihubuser/prod/.env
echo "Configured TZ"
sleep 1

#configure hostnames in env

sed -i "s%PUBLIC_DOMAIN=platform.rapidminer.com%PUBLIC_DOMAIN=$aihubhostname%g" /home/$aihubuser/prod/.env
sed -i "s%PUBLIC_URL=https://platform.rapidminer.com%PUBLIC_URL=http://$aihubhostname%g" /home/$aihubuser/prod/.env
sed -i "s%SSO_PUBLIC_URL=https://platform.rapidminer.com%SSO_PUBLIC_URL=http://$aihubhostname%g" /home/$aihubuser/prod/.env
echo "Configured hostnames"
sleep 1


#generate fresh keycloak secret
echo "Generating fresh keycloak secret..."
sleep 2
freshkeycloak=`echo $RANDOM | md5sum | head -c 20; echo | base64`
echo $freshkeycloak

sed -i "s/AUTH_SECRET=TTY5MjUxbzRBN2ZIWThpNGVKNGo4V2xqOHk0dTNV/AUTH_SECRET=$freshkeycloak/g" /home/$aihubuser/prod/.env

#write in a new password 

sed -i "s/KEYCLOAK_PASSWORD=changeit/KEYCLOAK_PASSWORD=$aihubpassword/g" /home/$aihubuser/prod/.env
echo "Keycloak configured"
sleep 1

sed -i "s%SERVER_LICENSE=%SERVER_LICENSE=$aihublicense%g" /home/$aihubuser/prod/.env
echo "License configured"
sleep 1



#create the ssl directory
mkdir -p /home/$aihubuser/prod/ssl



#chown and chmod it
chown -R $aihubuser:$aihubuser /home/$aihubuser/prod
chmod -R 750 /home/$aihubuser/prod
chmod a+rw /home/$aihubuser/prod/.env
chown -R 2011:0 /home/$aihubuser/prod/ssl/
chmod -R ug+w /home/$aihubuser/prod/ssl/
chmod -R o-rwx /home/$aihubuser/prod/ssl/
echo "Created ssl directory and added permissions."
sleep 1





#output document
#give the join address
#give the start commands for init
#give the start commands for startup
sleep 2
echo "==============IMPORTANT INSTRUCTIONS TO SAVE AND EXECUTE==============="
echo "To start the cluster, run the following commands as \"$aihubuser\""
echo ""
echo "cd /home/$aihubuser/prod"
echo "docker compose up -d rm-init-svc; docker compose logs -f"
echo ""
echo "Then wait several minutes for some installation to complete"
echo "This is the message that indicates completion:"
echo "[RapidMiner Server initialization] Waiting for RapidMiner Server startup and license load to initialize python configuration"
echo ""
echo "Interrupt logs with Control-C. Then you should run this command:"
echo ""
echo "docker compose down"
echo ""
echo "Followed by these commands"
echo ""
echo "docker compose up -d; docker compose logs -f"
echo ""
echo "Wait many minutes for this to complete.  Sometimes 15 minutes or more"
echo "When finished, you can access the AI-Hub at http://$aihubhostname"
echo "Your configuration is stored at /home/$aihubuser/prod/.env"
echo "It is a hidden file, so use ls -a to see it.  Make backups when editing"
echo ""
echo "Optional Encryption:"
echo "If you have SSL certificates, place them in /home/$aihubuser/prod/ssl/"
echo "You must update the .env file domain to have https"
echo "The certifcates must be in PEM format and named certificate.crt and private.key"
echo "======================================================================"
exit 0
