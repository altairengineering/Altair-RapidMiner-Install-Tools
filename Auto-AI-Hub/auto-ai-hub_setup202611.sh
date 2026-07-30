#!/bin/bash
set -o errexit -o pipefail -o noclobber -o nounset
function logverbose () {
    if [[ $VERBOSE -eq 1 ]]; then
        echo "$@"
    fi
}




#config
hubversion="2026.1.1"
PrefixHostname="auto-ai-hub"
VERBOSE=0
CREDLIC=0
UniqueHostname=""
NL=$'\n'
#startup reqs
[ $# -eq 0 ] && { echo "Usage: $0 username"; exit 1; }
[ "$(whoami)" = root ] || { echo 'you must first use sudo su - '; exit 1; }

#welcome banner
printf "\n"
echo "Auto-AI-Hub Setup script"
echo "SIEMENS - Anthony Kiehl"
echo "Version 1.0 - 6/9/26 Initial Release"
echo "Special thanks to Sebastian L. and Geetha T."
echo "Auto-AI-hub version $hubversion"
echo "======================================================================"
sleep 1


#checking if user is real
#aihubuser="$1"

#check the arguements manually and shift the values to parse them all
for i in "$@"; do
  case $i in
    -u=*|--username=*)
      AIHUBUSER="${i#*=}"
	  shift # past argument=value
      ;;
    -p=*|--password=*)
      ADMINPASSWORD="${i#*=}"
      shift # past argument=value
      ;;
    -d=*|--directory=*)
      HOMEDIRECTORY="${i#*=}"
      shift # past argument=value
      ;;
    -h=*|--hostname=*)
      HOSTLIC="${i#*=}"
      shift # past argument=value
      ;;
    -P=*|--port=*)
      PORTLIC="${i#*=}"
      shift # past argument=value
      ;;
    -c=*|--credentials=*)
      CREDLIC=1
      shift # past argument=value
      ;;	  
    -v|--verbose)
      VERBOSE=1
      shift # past argument with no value
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *|-h)
	  echo 'Usage:'
	  echo ' auto-ai-hub.sh <parameters>'
	  echo ''
	  echo 'Create an AI-Hub automatically.'
	  echo ''
	  echo 'Options:'
	  echo ' -u, --username=<username>   	        MANDATORY. Specify the linux username that will operate the AI-Hub'
	  echo ' -p, --password=<aihub_password>        MANDATORY. Admin password cannot contain special characters or spaces'
	  echo ' -d, --directory=<path>        	    	The directory to install into, by default will install to home folder'
	  echo ' -h, --hostname=<hostname>    	        This is the hostname to the license server. Defaults to 127.0.0.1'
	  echo ' -P, --port=<port>					    Network port number for the license server.  Defaults to 6200'	
	  echo ' -w, --webprefix=<string>			    Unique webaddress prefix to URL for AI-Hub.  Defaults to auto-ai-hub'		  
	  echo ' -c, --credentials                      Prompts user for license login.  Ignores license hostname and port'
	  echo ' -v, --verbose                          Run the command with extra output'
	  echo 'Examples:'
	  echo 'auto-ai-hub.sh -u john -p agoodpassword'
	  echo 'auto-ai-hub.sh -u john -p agoodpassword -d /opt/autoaihub -h 10.0.15.100 -P 6201'
	  echo 'auto-ai-hub.sh --username=john --password=agoodpassword --credentials --verbose'
	  echo 'Will install for user john in /opt/autoaihub and seek a license server at 10.0.15.100 running on port 6201'
      ;;
  esac
done
if [ ! -d ${HOMEDIRECTORY} ]; then
	mkdir -p ${HOMEDIRECTORY}
	if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
else	
	logverbose() "Found ${HOMEDIRECTORY}"
fi
logverbose() "Setting up permissions for ${HOMEDIRECTORY} to $AIHUBUSER"
chown -R $AIHUBUSER:$AIHUBUSER ${HOMEDIRECTORY}
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command

#check operating system
OperatingSystem=$(grep '^NAME=' /etc/os-release | cut -f 2 -d '"' | tr '[:lower:]' '[:upper:]')
logverbose() "$OperatingSystem detected"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
logverbose() "Attempting to install docker"
#execute docker installer scripts with case
{ #try
case $OperatingSystem in

  "RED HAT ENTERPRIZE LINUX")
    logverbose() "Detected Red Hat operating system"
	if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
	dnf update -y
	dnf upgrade -y
	dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc
	dnf install -y curl wget vim unzip openssl git
	dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	sed -i 's/rhel/centos/g' /etc/yum.repos.d/docker-ce.repo
	dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
	dnf update -y
	dnf install -y haveged
	dnf install -y docker-ce docker-ce-cli containerd.io
  ;;

  "ROCKY LINUX")
    logverbose() "Detected Rocky operating system"
	if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
	dnf update -y
	dnf upgrade -y
	dnf remove -y docker*
	dnf install -y epel-release
	dnf install -y dnf-utils curl wget vim unzip openssl git
	dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	dnf update -y --allowerasing
	dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --allowerasing
	dnf install -y haveged --allowerasing
  ;;

  "UBUNTU")
    logverbose() "Detected Ubuntu operating system"
	if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
	DEBIAN_FRONTEND=noninteractive apt-get update -y
	DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
	DEBIAN_FRONTEND=noninteractive apt-get remove -y docker docker.io containerd runc
	DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
	DEBIAN_FRONTEND=noninteractive apt-get install -y unzip curl wget vim ca-certificates net-tools gnupg lsb-release haveged openssl git
	curl -kfsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	DEBIAN_FRONTEND=noninteractive apt-get update -y
	DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io

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
systemctl enable --now docker
systemctl enable --now haveged
usermod -aG docker $AIHUBUSER

dockerver=$(docker --version | cut -d " " -f 3 | sed 's/,$//')
logverbose() "Docker version $dockerver"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command


#install ai-hub via automation
#download ai-hub and echo the version
logverbose() "Downloading and installing AI-Hub"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
logverbose() "Downloading $hubversion from https://docs.rapidminer.com/assets/download/hub/rapidminer-ai-hub-2026.1.1-docker-compose-template-prod.zip"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
wget -P "${HOMEDIRECTORY}" https://docs.rapidminer.com/assets/download/hub/rapidminer-ai-hub-"$hubversion"-docker-compose-template-prod.zip --output-document="${HOMEDIRECTORY}"/rapidminer-ai-hub-"$hubversion"-docker-compose-template-prod.zip
logverbose() "Extracting data"
unzip -o "${HOMEDIRECTORY}"/rapidminer-ai-hub-"$hubversion"-docker-compose-template-prod.zip -d "${HOMEDIRECTORY}"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command

ls "${HOMEDIRECTORY}"/prod
logverbose() "Files staged in prod folder"
#sed commands
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command

linuxtimezone=$(timedatectl | grep "Time zone" | tr -s " " | cut -f 4 -d ' ')
sed -i "s%TZ=UTC%TZ=${linuxtimezone}%g" "${HOMEDIRECTORY}"/prod/.env
logverbose() "Configured TZ"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command


#create the cert folder if its not already there
mkdir -p "${HOMEDIRECTORY}"/my-certs
#check if there is already been a unique id generated to prevent collisions during testing
if [ ! -f "${HOMEDIRECTORY}"/my-certs/UniqueID ]; then
	cat >> "${HOMEDIRECTORY}"/my-certs/UniqueID << 'END'
#UniqueHostnameIdentifier
UniqueHostname=target
END
	UniqueIdentifier=$(tr -dc a-f0-9 </dev/urandom | head -c 6)
	sed -i "s/target/$UniqueIdentifier/g" "${HOMEDIRECTORY}"/my-certs/UniqueID
fi
#read the source with the unique id and write it into the config
source "${HOMEDIRECTORY}"/my-certs/UniqueID
sed -i "s%PUBLIC_DOMAIN=platform.rapidminer.com%PUBLIC_DOMAIN=${PrefixHostname}-${UniqueHostname}.local%g" /home/"$AIHUBUSER"/prod/.env
sed -i "s%SSO_PUBLIC_DOMAIN=platform.rapidminer.com%SSO_PUBLIC_DOMAIN=${PrefixHostname}-${UniqueHostname}.local%g" /home/"$AIHUBUSER"/prod/.env
logverbose() "Configured hostnames"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command


#generate fresh keycloak secret
logverbose() "Generating fresh keycloak secret..."
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
freshkeycloak="$(echo $RANDOM | md5sum | head -c 20; echo | base64)"
logverbose() "$freshkeycloak"
sed -i "s/AUTH_SECRET=\"<AUTH-SECRET-PLACEHOLDER>\"/AUTH_SECRET=\"${freshkeycloak}\"/g" /home/"$AIHUBUSER"/prod/.env

#generate active mq password
logverbose() "Generating ActiveMQ password..."
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
activemqpassword="$(echo $RANDOM | md5sum | head -c 15)"
logverbose() "$activemqpassword"
sed -i "s/BROKER_ACTIVEMQ_PASSWORD=\"<SERVER-AMQ-PASS-PLACEHOLDER>\"/BROKER_ACTIVEMQ_PASSWORD=${activemqpassword}/g" "${HOMEDIRECTORY}"/prod/.env
sed -i "s/KEYCLOAK_DBPASS=changeit/KEYCLOAK_DBPASS=$ADMINPASSWORD/g" "${HOMEDIRECTORY}"/prod/.env
logverbose() "Platform admin creds configured"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
sed -i "s/KC_BOOTSTRAP_ADMIN_PASSWORD=changeit/KC_BOOTSTRAP_ADMIN_PASSWORD=${ADMINPASSWORD}/g" "${HOMEDIRECTORY}"/prod/.env
logverbose() "Keycloak database configured"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command

#create jupyterhub secret
JupyterCryptKey=$(openssl rand -hex 32)
sed -i "s%JUPYTERHUB_CRYPT_KEY=\"<JUPYTERHUB-CRYPT-KEY-PLACEHOLDER>\"%JUPYTERHUB_CRYPT_KEY=""${JupyterCryptKey}""%g" "${HOMEDIRECTORY}"/prod/.env
logverbose() "Jupyter Hub secret configured"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command

#credentials license
if [ "$CREDLIC" -eq 1 ]; then
	echo "Please enter License Unit Manager User Name (email address for Siemens AltairOne):"
	read -r LicenseUser
	echo "Please carefully enter License Unit Manager Password (creds for Siemens AltairOne):"
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
	sed -i "s/LICENSE_UNIT_MANAGER_USER_NAME=/LICENSE_UNIT_MANAGER_USER_NAME=${LicenseUser}/g" "${HOMEDIRECTORY}"/prod/.env
	sed -i "s/LICENSE_PROXY_MODE=on_prem/LICENSE_PROXY_MODE=altair_one/g" "${HOMEDIRECTORY}"/prod/.env
	sed -i "s/LICENSE_UNIT_MANAGER_PASSWORD=/LICENSE_UNIT_MANAGER_PASSWORD=${LicenseUserPassword}/g" "${HOMEDIRECTORY}"/prod/.env
else
#on prem license
	logverbose() "User did not specify \"creds\" as a command argument, defaulting to prem license server."
	if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
	LicensePath="${PORTLIC}@${HOSTLIC}"
	logverbose() "Setting license data to ${PORTLIC}@${HOSTLIC}"
	if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
	logverbose() "Installing On Prem Altair License"
	if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
	sed -i "s%ALTAIR_LICENSE_PATH=%ALTAIR_LICENSE_PATH="${LicensePath}"%g" "${HOMEDIRECTORY}"/prod/.env
fi

LicenseAgentID="$(openssl rand -hex 4)-$(openssl rand -hex 2)-$(openssl rand -hex 2)-$(openssl rand -hex 2)-$(openssl rand -hex 6)"
logverbose() "Machine ID = $LicenseAgentID"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
sed -i "s/LICENSE_AGENT_MACHINE_ID=\"\"/LICENSE_AGENT_MACHINE_ID=\"${LicenseAgentID}\"/g" "${HOMEDIRECTORY}"/prod/.env
sed -i "s/LICENSE_AGENT_MACHINE_ID=\"00000000-0000-0000-0000-000000000000\"/LICENSE_AGENT_MACHINE_ID=\"${LicenseAgentID}\"/g" "${HOMEDIRECTORY}"/prod/.env
logverbose() "License configured"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command

#1031 Pano mac address creation for altair one licensing
PanoGenMAC=$(cat /dev/urandom | tr -d -c '[:digit:]A-F' | fold -w 12 | sed -E -n -e '/^.[26AE]/s/(..)/\1-/gp' | sed -e 's/-$//g' |sed 's/-/:/g'| head -n1 | sed 's/^\S\S/66/g')
logverbose() "Panopticon Generated MAC address = $PanoGenMAC"
sed -i "s/PANOPTICON_VIZAPP_CONTAINER_MAC_ADDRESS=\"<PANOPTICON-MAC-ADDRESS-PLACEHOLDER>\"/PANOPTICON_VIZAPP_CONTAINER_MAC_ADDRESS=\"${PanoGenMAC}\"/g" "${HOMEDIRECTORY}"/prod/.env
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command

#custom cert fix
sed -i 's%CUSTOM_CA_CERTS_FILE=.*%CUSTOM_CA_CERTS_FILE=certificate.crt%g' "${HOMEDIRECTORY}"/prod/.env
logverbose() "Added custom ca certs file"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command

#create the ssl directory
mkdir -p "${HOMEDIRECTORY}"/prod/ssl
mkdir -p "${HOMEDIRECTORY}"/prod/panopticon
logverbose() "Created pano and ssl directories"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command

#chown and chmod it
chown -R "${aihubuser}":"${aihubuser}" "${HOMEDIRECTORY}"/prod
chmod -R 750 "${HOMEDIRECTORY}"/prod
chmod a+rw "${HOMEDIRECTORY}"/prod/.env
chown -R 2011:0 "${HOMEDIRECTORY}"/prod/ssl/
chmod -R ug+w "${HOMEDIRECTORY}"/prod/ssl/
chmod -R o-rwx "${HOMEDIRECTORY}"/prod/ssl/
chown -R 2011:0 "${HOMEDIRECTORY}"/prod/panopticon/
chmod -R ug+w "${HOMEDIRECTORY}"/prod/panopticon/
chmod -R o-rwx "${HOMEDIRECTORY}"/prod/panopticon/
logverbose() "Modified directory permissions"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command

read -n 1 -s -r -p "Finished AI-Hub file staging.  Press any key to continue${NL}"
#creating certificate authority
logverbose() "Creating cryptography setup"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
#collect networking data
MainAdapter=$(route | grep default | tr -s ' ' | cut -f 8 -d ' ')
FunctionalAddress=$(ip addr show "$MainAdapter" | grep -w inet | awk '{print $2}' | sed "s%\/.*%%g")
logverbose() "Network data"
logverbose() "$MainAdapter $FunctionalAddress"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
#create ca cert and key
CASharedSubject="/C=US/O=RapidMiner/OU=AutoAIHub/CN=${PrefixHostname}-${UniqueHostname}.local"
logverbose() "Shared Subject is ${CASharedSubject}"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
logverbose() "Creating self signed root trust key and certificate"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
openssl genpkey -out "${HOMEDIRECTORY}"/my-certs/ca-root.key -outform PEM -algorithm RSA -pkeyopt rsa_keygen_bits:4096
logverbose() "Created private ca key, now creating ca root certificate"
openssl req -x509 -new -nodes -key "${HOMEDIRECTORY}"/my-certs/ca-root.key -sha256 -days 3650 -subj "${CASharedSubject}" -out "${HOMEDIRECTORY}"/my-certs/ca-root.crt
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
logverbose() "Generating CSR"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
openssl req -new -nodes -outform PEM -out "${HOMEDIRECTORY}"/my-certs/server.csr -newkey rsa:4096 -keyout "${HOMEDIRECTORY}"/my-certs/private.key -subj "${CASharedSubject}"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
#create ca config
logverbose() "Creating ext config"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
cat >> "${HOMEDIRECTORY}"/my-certs/server.v3.ext << 'END'
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = <YOUR-SERVER-HOSTNAME>
IP.1 = <YOUR-SERVER-IP-ADDRESS>
END
logverbose() "Updating external config to point to ${PrefixHostname}-${UniqueHostname}.local at $FunctionalAddress"
sed -i "s%<YOUR-SERVER-HOSTNAME>%${PrefixHostname}-${UniqueHostname}.local%g" "${HOMEDIRECTORY}"/my-certs/server.v3.ext
sed -i "s%<YOUR-SERVER-IP-ADDRESS>%$FunctionalAddress%g" "${HOMEDIRECTORY}"/my-certs/server.v3.ext
logverbose() "Created ext config:"
if [ $VERBOSE -eq 1 ]; then cat "${HOMEDIRECTORY}"/my-certs/server.v3.ext; fi #debug output
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
logverbose() "Creating server certificate"
openssl x509 -req -in "${HOMEDIRECTORY}"/my-certs/server.csr -inform PEM -CA "${HOMEDIRECTORY}"/my-certs/ca-root.crt -CAform PEM -CAkey "${HOMEDIRECTORY}"/my-certs/ca-root.key -CAkeyform PEM -CAcreateserial -out "${HOMEDIRECTORY}"/my-certs/certificate.crt -outform PEM -days 1095 -sha256 -extfile "${HOMEDIRECTORY}"/my-certs/server.v3.ext 
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
if [ $VERBOSE -eq 1 ]; then ls -shalt "${HOMEDIRECTORY}"/my-certs/; fi #debug output
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
logverbose()  "Cryptography complete."
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
logverbose() "Pulling images from repositories"
until su -g docker -c "docker compose -f ${HOMEDIRECTORY}/prod/docker-compose.yml pull"; do echo retrying; done
#run deployment-init to generate backend
logverbose() "Starting Auto-AI-Hub deployment-init"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
su -g docker -c "docker compose -f ${HOMEDIRECTORY}/prod/docker-compose.yml up -d deployment-init" "$AIHUBUSER"
su -g docker -c "docker compose -f "${HOMEDIRECTORY}"/prod/docker-compose.yml logs -f" "$AIHUBUSER" | while read -r LOGLINE
do
    logverbose() "$LOGLINE"
    [[ "${LOGLINE}" == *"deployment-init-1 exited with code"* ]] && echo "!!!executing changes based on logs!!!" && su -g docker -c "docker compose -f ${HOMEDIRECTORY}/prod/docker-compose.yml down" "$AIHUBUSER"
done
logverbose() "Deployment-init complete."
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
#move certificates to proper folder
logverbose() "Staging Certificates"
cp "${HOMEDIRECTORY}"/my-certs/certificate.crt "${HOMEDIRECTORY}"/prod/ssl/
cp "${HOMEDIRECTORY}"/my-certs/private.key "${HOMEDIRECTORY}"/prod/ssl/
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
logverbose() "Merging root trust"
cat "${HOMEDIRECTORY}"/my-certs/ca-root.crt >> "${HOMEDIRECTORY}"/my-certs/certificate.crt
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
#run prepare-cust-ca.sh
logverbose() "Executing prepare-cust-ca.sh"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
cd "${HOMEDIRECTORY}"/prod
bash ./prepare-cust-ca.sh
chown "$AIHUBUSER":"$AIHUBUSER" "${HOMEDIRECTORY}"/prod/docker-compose.yml
read -n 1 -s -r -p "Prepare-cust-ca.sh completed."
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
logverbose() "Starting up AI-Hub"
su -g docker -c "docker compose -f ${HOMEDIRECTORY}/prod/docker-compose.yml up -d" "$AIHUBUSER"
logverbose() "Script complete"
if [ $VERBOSE -eq 1 ]; then sleep 1; fi #sleep command
if [ $VERBOSE -eq 1 ]; then docker ps; fi #debug output

#finish script with documentation output
echo ""
echo ""
echo "============================================================="
echo "Auto-AI-Hub Setup Completed!"
echo "-------------------------------------------------------------"
echo "Please save the following information somewhere securely:"
echo "AI-Hub Hostname: ${PrefixHostname}-${UniqueHostname}.local"
echo "AI-Hub IP Address: $FunctionalAddress"
echo "AI-Hub login/password:  admin/${ADMINPASSWORD}"
echo "Please wait 5-10 minutes for the system to fully startup"
echo "-------------------------------------------------------------"
echo "YOU WILL ALMOST CERTAINLY NEED TO ADD THE FOLLOWING LINE"
echo "OF HOSTNAMES TO YOUR PC/LAPTOP \"HOSTS\" FILE TO USE THE AI-HUB"
echo "-------------------------------------------------------------"
echo "$FunctionalAddress       ${PrefixHostname}-${UniqueHostname}.local       ${PrefixHostname}-${UniqueHostname}"
echo ""
echo "-------------------------------------------------------------"
echo "When completed, browse to https://${PrefixHostname}-${UniqueHostname}.local"
echo "============================================================="
echo ""
exit 0



