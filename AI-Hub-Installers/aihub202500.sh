#!/bin/bash
#config
hubversion="2025.0.0"
#main
[ "$(whoami)" = root ] || { echo 'you must run with sudo'; exit 1; }

#promts:
printf "\n"
echo "AI-Hub install helper"
echo "ALTAIR - Anthony Kiehl"
echo "Version 2.01 - 12/16/24 202500 support"
echo "Version 2.0 - 9/11/24 202410 support"
echo "Version 1.81 - 8/1/24 202403 support"
echo "Version 1.7 - 4/3/24 2024 series support"
echo "Version 1.6 - 1/24/24 10.3.1 support"
echo "Version 1.5 - 8/16/23 10.3.0 support"
echo "Version 1.41 - 8/16/23 10.2.0 support"
echo "Version 1.4 - 6/15/23 added license fix"
echo "Version 1.3 - 6/6/23 Added Altair License"
echo "Version 1.2 - Updated to 1012 3/30/23"
echo "Version 1.12 - Fixed file structures 11/22/22"
echo "Version 1.1 - Added version checking and bugfixes 11/3/22"
echo "Version 1.0 - Initial Release 9/20/22"
echo "Special thanks to Zhanna A. and Sharan G."
echo "AI-hub version $hubversion"
echo "======================================================================"
sleep 1
echo "Detecting Docker and Docker-Compose versions"
sleep 1
dockerver=$(docker --version | cut -d " " -f 3 | sed 's/,$//')
echo "Detected Docker $dockerver"
sleep 1

composever=$(docker compose version | cut -d " " -f 4 | sed 's/,$//')
echo "Detected Compose $composever"
sleep 1

echo "If you want to use the configuration file for automated installation choices, press Cntl-C.  Then use the absolute or relative path to the configuration file, after filling it out."
read -n1 -r -p "Press any key to continue, or Cntl-C to exit without installing"

if [ -z "$1" ]; then


	#user name
	echo ""
	echo "Please enter the exact name of the linux user, not root, for whom docker has been enabled with access:" 
	read -r aihubuser
	
	if [ -d /home/"$aihubuser"/ ];
	then
		echo "Found $aihubuser"
	else	
		echo "$aihubuser is not correct or does not have a home folder"
		exit 1
	fi


	#hostname or ip
	echo 'Please enter the complete FQDN of the server.  Alternatively, you may use IP address but never localhost:' 
	read -r aihubhostname

	#timezone
	echo "Please enter a timezone using the example format.  Example: America/New_York"
	read -r linuxtimezone

	#enter a passphrase twice
	echo 'Please carefully enter the password to use for the admin account on ai-hub website, which we can use after it launches:' 
	read -r -s aihubpasswordfirst
	echo "Please re-enter password:" 
	read -r -s aihubpasswordsecond
	if [ "$aihubpasswordfirst" == "$aihubpasswordsecond" ]; then
		echo "Password recorded"
		aihubpassword=$aihubpasswordfirst
	#	echo "DEBUG: $aihubpassword"
	else
		echo "Passwords did not match"
		exit 1
	fi


	#licensing section
	
		echo "Please choose License Mode:"
		echo "On-prem \"O\""
		echo "Altair One Credentials \"C\""
		echo "Altair One Auth Code \"A\""
		echo "RapidMiner Legacy \"L\""
		read -r LicenseMode
	        LicenseMode=$(echo "${LicenseMode}" | tr a-z A-Z)
                echo ""	
		case $LicenseMode in
			"O")
				echo "Please enter Altair License Manager path for on-prem mode pointing to an Altair Lincense Manager endpoint in format of \"port@host\".  Example: 6200@127.0.0.1 (Press control-c to cancel)"
				read -r LicensePath
				;;
			"C")
				echo "Please enter License Unit Manager User Name (email address for AltairOne):"
				read -r LicenseUser
				echo "Please carefully enter License Unit Manager Password (creds for AltairOne):"
				read -r -s LicenseUserPasswordfirst
				echo "Please re-enter password:"
				read -r -s LicenseUserPasswordsecond
				if [ "$LicenseUserPasswordfirst" == "$LicenseUserPasswordsecond" ]; then
	        			echo "Password recorded"
        				LicenseUserPassword=$LicenseUserPasswordfirst
				else
        				echo "Passwords did not match"
        				exit 1
				fi
				;;

                        "A")
                                echo "Please enter Altair License \"Auth Code\" which can be created on the Altair One website.  (Press control-c to cancel)"
                                read -r LicenseAuthCode
                                ;;

			"L")
				echo "Please paste your ai-hub license (ctrl-C to quit):" 
				echo ""
				read -r aihublicense
	
				;;


		esac


else
#here we read the config file
# shellcheck source=$1
source "$1"

fi


#install ai-hub
#download ai-hub and echo the version
echo "Downloading and installing AI-Hub"
sleep 1
#https://docs.rapidminer.com/assets/download/hub/rapidminer-ai-hub-2025.0.0-docker-compose-template-prod.zip
echo "Downloading $hubversion from https://docs.rapidminer.com/assets/download/hub/rapidminer-ai-hub-$hubversion-docker-compose-template-prod.zip"
sleep 1
wget -P /home/"$aihubuser" https://docs.rapidminer.com/assets/download/hub/rapidminer-ai-hub-"$hubversion"-docker-compose-template-prod.zip
echo "Extracting data"
cd /home/"$aihubuser" && unzip /home/"$aihubuser"/rapidminer-ai-hub-"$hubversion"-docker-compose-template-prod.zip
sleep 1

ls /home/"$aihubuser"/prod
echo "Files staged in prod folder"
#sed commands
sleep 1

sed -i "s%TZ=UTC%TZ=${linuxtimezone}%g" /home/"${aihubuser}"/prod/.env
echo "Configured TZ"
sleep 1

#configure hostnames in env

sed -i "s%PUBLIC_DOMAIN=platform.rapidminer.com%PUBLIC_DOMAIN=${aihubhostname}%g" /home/"$aihubuser"/prod/.env
#sed -i "s%PUBLIC_URL=http://platform.rapidminer.com%PUBLIC_URL=http://${aihubhostname}%g" /home/"$aihubuser"/prod/.env
sed -i "s%SSO_PUBLIC_DOMAIN=platform.rapidminer.com%SSO_PUBLIC_DOMAIN=${aihubhostname}%g" /home/"$aihubuser"/prod/.env
#sed -i "s%SSO_PUBLIC_URL=http://platform.rapidminer.com%SSO_PUBLIC_URL=http://${aihubhostname}%g" /home/"$aihubuser"/prod/.env
echo "Configured hostnames"
sleep 1


#generate fresh keycloak secret
echo "Generating fresh keycloak secret..."
sleep 1
freshkeycloak="$(echo $RANDOM | md5sum | head -c 20; echo | base64)"
echo "$freshkeycloak"
sed -i "s/AUTH_SECRET=\"<AUTH-SECRET-PLACEHOLDER>\"/AUTH_SECRET=\"${freshkeycloak}\"/g" /home/"$aihubuser"/prod/.env

#generate active mq password
echo "Generating ActiveMQ password..."
sleep 1
activemqpassword="$(echo $RANDOM | md5sum | head -c 15)"
echo "$activemqpassword"
sed -i "s/BROKER_ACTIVEMQ_PASSWORD=\"<SERVER-AMQ-PASS-PLACEHOLDER>\"/BROKER_ACTIVEMQ_PASSWORD=${activemqpassword}/g" /home/"$aihubuser"/prod/.env

sed -i "s/KEYCLOAK_PASSWORD=changeit/KEYCLOAK_PASSWORD=${aihubpassword}/g" /home/"$aihubuser"/prod/.env
echo "Keycloak configured"
sleep 1

#create jupyterhub secret
#JUPYTERHUB_CRYPT_KEY="<JUPYTERHUB-CRYPT-KEY-PLACEHOLDER>"
JupyterCryptKey=$(openssl rand -hex 32)
sed -i "s%JUPYTERHUB_CRYPT_KEY=\"<JUPYTERHUB-CRYPT-KEY-PLACEHOLDER>\"%JUPYTERHUB_CRYPT_KEY=""${JupyterCryptKey}""%g" /home/"$aihubuser"/prod/.env
echo "Jupyter Hub secret configured"
sleep 1

#sed -i "s%  jupyterhub:%  jupyterhub:\\n    user: root\n%g" /home/"$aihubuser"/prod/docker-compose.yml
#echo "Jupyter Hub user: root appended"

case $LicenseMode in
	"L")
		#legacy license
		echo "Disabling Altair License, talk to your sales rep for more info"      
		sleep 1
		sed -i "s/# Providing LICENSE variable is colliding with LICENSE_ENABLE_ALTAIR, please provide this variable only if you have legacy license./LICENSE_ENABLE_ALTAIR=false/g" /home/"$aihubuser"/prod/.env
		sed -i "s/LICENSE_MODE=ALTAIR_UNIT/LICENSE_MODE=RAPIDMINER/g" /home/"$aihubuser"/prod/.env
		sed -i 's/      # - LICENSE_LICENSE=${LICENSE}/      - LICENSE_LICENSE=${LICENSE}/g' /home/"${aihubuser}"/prod/docker-compose.yml
		sed -i "s%^LICENSE=%LICENSE=${aihublicense}%g" /home/"$aihubuser"/prod/.env
		echo "$aihublicense" >> /home/"$aihubuser"/prod/license.lic

		sleep 1
		;;
		
	"O")
		#Altair On prem License
		echo "Installing On Prem Altair License"
		sleep 1
	#	sed -i "s/LICENSE_PROXY_MODE=altair_one/LICENSE_PROXY_MODE=on_prem/g" /home/$aihubuser/prod/.env
	        sed -i "s/ALTAIR_LICENSE_PATH=/ALTAIR_LICENSE_PATH=${LicensePath}/g" /home/"$aihubuser"/prod/.env

		;;

	"A")
		#Altair Auth Code
		echo "Installing Altair Auth Code"
		sleep 1
		sed -i "s/LICENSE_PROXY_MODE=on_prem/LICENSE_PROXY_MODE=altair_one/g" /home/"$aihubuser"/prod/.env
		sed -i "s/LICENSE_UNIT_MANAGER_AUTHENTICATION_TYPE=credentials/LICENSE_UNIT_MANAGER_AUTHENTICATION_TYPE=auth_code/g" /home/"$aihubuser"/prod/.env
	        sed -i "s/LICENSE_UNIT_MANAGER_AUTH_CODE=/LICENSE_UNIT_MANAGER_AUTH_CODE=${LicenseAuthCode}/g" /home/"$aihubuser"/prod/.env


		;;
	"C")
		#credentials license
		sed -i "s/LICENSE_UNIT_MANAGER_USER_NAME=/LICENSE_UNIT_MANAGER_USER_NAME=${LicenseUser}/g" /home/"${aihubuser}"/prod/.env
		sed -i "s/LICENSE_PROXY_MODE=on_prem/LICENSE_PROXY_MODE=altair_one/g" /home/"$aihubuser"/prod/.env
		sed -i "s/LICENSE_UNIT_MANAGER_PASSWORD=/LICENSE_UNIT_MANAGER_PASSWORD=${LicenseUserPassword}/g" /home/"$aihubuser"/prod/.env
##at the end of the script, we must pull the auth.json from the security container

		;;
esac

LicenseAgentID="$(openssl rand -hex 4)-$(openssl rand -hex 2)-$(openssl rand -hex 2)-$(openssl rand -hex 2)-$(openssl rand -hex 6)"
echo "Machine ID = $LicenseAgentID"
sleep 1
sed -i "s/LICENSE_AGENT_MACHINE_ID=\"\"/LICENSE_AGENT_MACHINE_ID=\"${LicenseAgentID}\"/g" /home/"${aihubuser}"/prod/.env
sed -i "s/LICENSE_AGENT_MACHINE_ID=\"00000000-0000-0000-0000-000000000000\"/LICENSE_AGENT_MACHINE_ID=\"${LicenseAgentID}\"/g" /home/"${aihubuser}"/prod/.env


echo "License configured"
sleep 1


#1031 Pano mac address creation for altair one licensing
PanoGenMAC=$(cat /dev/urandom | tr -d -c '[:digit:]A-F' | fold -w 12 | sed -E -n -e '/^.[26AE]/s/(..)/\1-/gp' | sed -e 's/-$//g' |sed 's/-/:/g'| head -n1 | sed 's/^\S\S/66/g')
echo "Panopticon Generated MAC address = $PanoGenMAC"
sed -i "s/PANOPTICON_VIZAPP_CONTAINER_MAC_ADDRESS=\"<PANOPTICON-MAC-ADDRESS-PLACEHOLDER>\"/PANOPTICON_VIZAPP_CONTAINER_MAC_ADDRESS=\"${PanoGenMAC}\"/g" /home/"${aihubuser}"/prod/.env


#pano user fix
sed -i 's%    hostname: panopticon-vizapp$%    hostname: panopticon-vizapp\n    user: root%g' /home/"${aihubuser}"/prod/docker-compose.yml
sed -i "s%    hostname: panopticon-vizapp-python%    hostname: panopticon-vizapp-python\n    user: root%g" /home/"${aihubuser}"/prod/docker-compose.yml
sed -i "s%    hostname: panopticon-monetdb%    hostname: panopticon-monetdb\n    user: root%g" /home/"${aihubuser}"/prod/docker-compose.yml
sed -i "s%    hostname: panopticon-rserve%    hostname: panopticon-rserve\n    user: root%g" /home/"${aihubuser}"/prod/docker-compose.yml
echo "Added pano user:root fix"

#suse jupyter fix
if $(cat /proc/version | grep -qi 'suse'); then
  sed -i 's%    hostname: jupyterhub$%    hostname: jupyterhub\n    user: root%g' /home/"${aihubuser}"/prod/docker-compose.yml
  echo "Added fix for SUSE and jupyterhub"
fi
sleep 1
#custom cert fix
sed -i 's%CUSTOM_CA_CERTS_FILE=.*%CUSTOM_CA_CERTS_FILE=certificate.crt%g' /home/"$aihubuser"/prod/.env
echo "Added custom ca certs file"

#create the ssl directory
mkdir -p /home/"${aihubuser}"/prod/ssl
sleep 1
#chown and chmod it
chown -R "${aihubuser}":"${aihubuser}" /home/"${aihubuser}"/prod
chmod -R 750 /home/"${aihubuser}"/prod
chmod a+rw /home/"${aihubuser}"/prod/.env
chown -R 2011:0 /home/"${aihubuser}"/prod/ssl/
chmod -R ug+w /home/"${aihubuser}"/prod/ssl/
chmod -R o-rwx /home/"${aihubuser}"/prod/ssl/
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
echo "docker compose pull"
echo ""
echo "docker compose up -d deployment-init; docker compose logs -f"
echo ""
echo "Then wait several minutes for some installation to complete"
echo "This is the message that indicates completion:"
echo "[DEPLOYMENT INIT] Successfully finished."
echo "or"
echo "[RapidMiner Server initialization] Waiting for RapidMiner Server startup and license load to initialize python configuration"
echo ""
echo "Interrupt logs with Control-C."
echo ""
echo "docker compose down"
echo ""
echo "You must install a certificate.crt and a private.key into the ssl folder in pem format"
echo ""
echo "then run this script as root:"
echo "./prepare_cust_ca.sh"
echo ""
echo "now you can bring up the full stack with:"
echo "docker compose up -d; docker compose logs -f"
echo ""
echo "Wait many minutes for this to complete.  Sometimes 15 minutes or more"
echo "When finished, you can access the AI-Hub at https://$aihubhostname"
echo "Your configuration is stored at /home/$aihubuser/prod/.env"
echo "It is a hidden file, so use ls -a to see it.  Make backups when editing."
echo "Full backups are advisable for the entire system, and to never restart the"
echo "host while docker container services are active."
echo "======================================================================"
exit 0
