#!/bin/bash
#config
hubversion="2026.1.1"
#startup reqs
[ $# -eq 0 ] && { echo "Usage: $0 username"; exit 1; }
[ "$(whoami)" = root ] || { echo 'you must run with sudo'; exit 1; }

#welcome banner
printf "\n"
echo "Auto-AI-Hub Setup script"
echo "SIEMENS - Anthony Kiehl"
echo "Version 1.0 - 6/9/26 Initial Release"
echo "Special thanks to Sebastian L., Lloyd L., and Nigesh P."
echo "Auto-AI-hub version $hubversion"
echo "======================================================================"
sleep 1

#checking necessary requirements
echo "Checking installation requirements"
sleep 1
if [ -e "../README.md" ]; then
  echo "Repository readme file present"
  sleep 1
else
  echo "Repository readme file not present"
  echo "Please install entire repo using git command:"
  echo "git clone https://github.com/altairengineering/Altair-RapidMiner-Install-Tools.git"
  echo "bye"
  exit 1
fi
#checking if user is real
aihubuser="$1"
if [ -d /home/"$aihubuser"/ ]; then
	echo "Found $aihubuser"
	sleep 1
else	
	echo "$aihubuser is not correct or does not have a home folder"
	exit 1
fi

#check operating system
OperatingSystem=$(grep '^NAME=' /etc/os-release | cut -f 2 -d '"' | tr '[:lower:]' '[:upper:]')
echo "$OperatingSystem detected"
sleep 1
echo "Attempting to install docker"
#execute docker installer scripts with case
{ #try
case $OperatingSystem in

  "RED HAT ENTERPRIZE LINUX")
    echo "Detected Red Hat operating system"
    chmod +x ../Docker-Installers/rhel.sh
    /bin/bash ../Docker-Installers/rhel.sh "$1"
  ;;

  "ROCKY LINUX")
    echo "Detected Rocky operating system"
    chmod +x ../Docker-Installers/rocky.sh
    /bin/bash ../Docker-Installers/rocky.sh "$1"
  ;;

  "UBUNTU")
    echo "Detected Ubuntu operating system"
    chmod +x ../Docker-Installers/ubuntu.sh
    /bin/bash ../Docker-Installers/ubuntu.sh "$1"
  ;;   

  *)
    echo "Non-supported operating system detected, please contact administrator."
    exit 1
  ;;
  
esac
} || { #catch
echo "Docker install case operation failed"
exit 1
}


dockerver=$(docker --version | cut -d " " -f 3 | sed 's/,$//')
echo "Docker version $dockerver"

sleep 1


#install ai-hub via automation



#install ai-hub
#download ai-hub and echo the version
echo "Downloading and installing AI-Hub"
sleep 1
echo "Downloading $hubversion from https://docs.rapidminer.com/assets/download/hub/rapidminer-ai-hub-2026.1.1-docker-compose-template-prod.zip"
sleep 1
wget -P /home/"$aihubuser" https://docs.rapidminer.com/assets/download/hub/rapidminer-ai-hub-"$hubversion"-docker-compose-template-prod.zip
echo "Extracting data"
cd /home/"$aihubuser" && unzip /home/"$aihubuser"/rapidminer-ai-hub-"$hubversion"-docker-compose-template-prod.zip
sleep 1

ls /home/"$aihubuser"/prod
echo "Files staged in prod folder"
#sed commands
sleep 1

linuxtimezone=$(timedatectl | grep "Time zone" | tr -s " " | cut -f 4 -d ' ')
sed -i "s%TZ=UTC%TZ=${linuxtimezone}%g" /home/"${aihubuser}"/prod/.env
echo "Configured TZ"
sleep 1

#configure hostnames in env
#create the folder if its not already there
mkdir -p /home/"${aihubuser}"/my-certs
UniqueHostname=""
#check if there is already been a unique id generated to prevent collisions during testing
if [ ! -f /home/"${aihubuser}"/my-certs/UniqueID ]; then
	cat >> /home/"${aihubuser}"/my-certs/UniqueID << 'END'
#UniqueHostnameIdentifier
UniqueHostname=target
END
	UniqueIdentifier=$(tr -dc a-f0-9 </dev/urandom | head -c 6)
	sed -i "s/target/$UniqueIdentifier/g" /home/"${aihubuser}"/my-certs/UniqueID
fi
#read the source with the unique id and write it into the config
source /home/"${aihubuser}"/my-certs/UniqueID
sed -i "s%PUBLIC_DOMAIN=platform.rapidminer.com%PUBLIC_DOMAIN=auto-ai-hub-$UniqueHostname.local%g" /home/"$aihubuser"/prod/.env
sed -i "s%SSO_PUBLIC_DOMAIN=platform.rapidminer.com%SSO_PUBLIC_DOMAIN=auto-ai-hub-$UniqueHostname.local%g" /home/"$aihubuser"/prod/.env
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
sed -i "s/KEYCLOAK_DBPASS=changeit/KEYCLOAK_DBPASS=rapidminerautoaihub/g" /home/"$aihubuser"/prod/.env
echo "Platform admin creds configured"
sleep 1
sed -i "s/KC_BOOTSTRAP_ADMIN_PASSWORD=changeit/KC_BOOTSTRAP_ADMIN_PASSWORD=rapidminerautoaihub/g" /home/"$aihubuser"/prod/.env
echo "Keycloak database configured"
sleep 1


#create jupyterhub secret
JupyterCryptKey=$(openssl rand -hex 32)
sed -i "s%JUPYTERHUB_CRYPT_KEY=\"<JUPYTERHUB-CRYPT-KEY-PLACEHOLDER>\"%JUPYTERHUB_CRYPT_KEY=""${JupyterCryptKey}""%g" /home/"$aihubuser"/prod/.env
echo "Jupyter Hub secret configured"
sleep 1

######################################ADD ON PREM LICENSE SETUP HERE###################################################################
#
#
#credentials license
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
sed -i "s/LICENSE_UNIT_MANAGER_USER_NAME=/LICENSE_UNIT_MANAGER_USER_NAME=${LicenseUser}/g" /home/"${aihubuser}"/prod/.env
sed -i "s/LICENSE_PROXY_MODE=on_prem/LICENSE_PROXY_MODE=altair_one/g" /home/"$aihubuser"/prod/.env
sed -i "s/LICENSE_UNIT_MANAGER_PASSWORD=/LICENSE_UNIT_MANAGER_PASSWORD=${LicenseUserPassword}/g" /home/"$aihubuser"/prod/.env


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

#custom cert fix
sed -i 's%CUSTOM_CA_CERTS_FILE=.*%CUSTOM_CA_CERTS_FILE=certificate.crt%g' /home/"$aihubuser"/prod/.env
echo "Added custom ca certs file"

#create the ssl directory
mkdir -p /home/"${aihubuser}"/prod/ssl
mkdir -p /home/"${aihubuser}"/prod/panopticon
echo "Created pano and ssl directories"

sleep 1
#chown and chmod it
chown -R "${aihubuser}":"${aihubuser}" /home/"${aihubuser}"/prod
chmod -R 750 /home/"${aihubuser}"/prod
chmod a+rw /home/"${aihubuser}"/prod/.env
chown -R 2011:0 /home/"${aihubuser}"/prod/ssl/
chmod -R ug+w /home/"${aihubuser}"/prod/ssl/
chmod -R o-rwx /home/"${aihubuser}"/prod/ssl/
chown -R 2011:0 /home/"${aihubuser}"/prod/panopticon/
chmod -R ug+w /home/"${aihubuser}"/prod/panopticon/
chmod -R o-rwx /home/"${aihubuser}"/prod/panopticon/
echo "Modified directory permissions"
sleep 1


#creating certificate authority
echo "Creating cryptography setup"
#collect networking data
MainAdapter=$(route | grep default | tr -s ' ' | cut -f 8 -d ' ')
FunctionalAddress=$(ip addr show "$MainAdapter" | grep -w inet | awk '{print $2}' | sed "s%\/.*%%g")
#create ca cert and key
CASharedSubject="/C=US/ST=WA/L=Seattle/O=RapidMiner/OU=AutoAIHub/CN=auto-ai-hub-$UniqueHostname.local"
openssl genrsa -aes256 -verbose -noenc -out /home/"${aihubuser}"/my-certs/ca-root.key 4096
openssl req -x509 -verbose -new -nodes -key /home/"${aihubuser}"/my-certs/ca-root.key -sha256 -days 3650 -subj "$CASharedSubject" -out /home/"${aihubuser}"/my-certs/ca-root.crt
openssl req -verbose -new -nodes -out /home/"${aihubuser}"/my-certs/server.csr -newkey rsa:4096 -keyout /home/"${aihubuser}"/my-certs/server.key -subj "$CASharedSubject"
#create ca config
cat >> /home/"${aihubuser}"/my-certs/server.v3.ext << 'END'
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = <YOUR-SERVER-HOSTNAME>
IP.1 = <YOUR-SERVER-IP-ADDRESS>
END
sed -i "s%<YOUR-SERVER-HOSTNAME>%auto-ai-hub-$UniqueHostname.local%g" /home/"${aihubuser}"/my-certs/server.v3.ext
sed -i "s%<YOUR-SERVER-IP-ADDRESS>%$FunctionalAddress%g" /home/"${aihubuser}"/my-certs/server.v3.ext
echo "Created CA config"
sleep 1
openssl x509 -req -in /home/"${aihubuser}"/my-certs/server.csr -CA /home/"${aihubuser}"/my-certs/ca-root.crt -CAkey /home/"${aihubuser}"/my-certs/my-root.key -CAcreateserial -out /home/"${aihubuser}"/my-certs/server.crt -days 1095 -sha256 -extfile /home/"${aihubuser}"/my-certs/server.v3.ext 
echo "Created server certificate"
sleep 2
#run deployment-init to generate backend
#echo "STARTING"
#docker compose -f /home/"${aihubuser}"/prod/docker-compose.yml up -d deployment-init
#echo "DEPLOYMENT HAS EXITED TO NEXT INSTRUCTIONS"
#docker compose logs -f | while read -r LOGLINE
#do
#    echo "$LOGLINE"
#    [[ "${LOGLINE}" == *"Successfully finished."* ]] && echo "!!!executing changes based on logs!!!" && docker compose down
#done
#echo "Script complete"
#exit 0

#move certificates to proper folder



#run prepare_cust_ca.sh



#finish script with documentation output

