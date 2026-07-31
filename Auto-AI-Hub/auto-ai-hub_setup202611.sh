#!/bin/bash
#error handling
set -o errexit -o pipefail -o noclobber -o nounset
#functions

declare echolog='logverbose'
function logverbose () { 
if [ "${VERBOSE}" -eq 1 ]; then echo "$@"; sleep 1; fi 
}

declare checkchars='charsanity'
function charsanity () {
$echolog "$@"
case "$@" in
  *['!&()'@#$%^*_+]* )
  echo 'You cannot use special characters for the password like !@#$%^&*()_+'
  exit 1 
  ;;
esac
}

declare documents='startsplash'
function startsplash () {
#welcome banner
printf "\n"
echo "Auto-AI-Hub Setup script"
echo "SIEMENS - Anthony Kiehl"
echo "Version 1.0 - 6/9/26 Initial Release"
echo "Special thanks to: Helge H, Sebastian L, Geetha T"
echo "Auto-AI-hub version ${hubversion}"
echo "======================================================================"
sleep 1
}

declare echodocs='helpfile'
function helpfile () {
      echo ''
      echo 'Usage:'
      echo ' auto-ai-hub.sh <parameters>'
      echo ''
      echo 'Create an AI-Hub automatically.'
      echo ''
      echo 'Options:'
      echo ' -u, --username=<username>          MANDATORY. Specify the linux username that will operate the AI-Hub'
      echo ' -p, --password=<aihub_password>    MANDATORY. Admin password cannot contain special characters or spaces'
      echo ' -d, --directory=<path>             The directory to install into, by default will install to home folder'
      echo ' -H, --hostname=<hostname>          This is the hostname to the license server. Defaults to 127.0.0.1'
      echo ' -P, --port=<port>                  Network port number for the license server.  Defaults to 6200'    
      echo ' -w, --webprefix=<string>           Unique webaddress prefix to URL for AI-Hub.  Defaults to auto-ai-hub'          
      echo ' -c, --credentials                  Prompts user for license login.  Ignores license hostname and port'
      echo ' -s, --skipdocker                   Skips the docker installation'
      echo ' -v, --verbose                      Run the command with extra output'
      echo ' -h, --help                         Displays this help document as output'
      echo 'Examples:'
      echo 'auto-ai-hub.sh -u=john -p=agoodpassword'
      echo 'auto-ai-hub.sh -u=john -p=agoodpassword -d=/opt/autoaihub -H=10.0.15.100 -P=6201'
      echo 'auto-ai-hub.sh --username=john --password=agoodpassword --credentials --verbose'
}

declare exitdocs='endfile'
function endfile () {
echo ""
echo "============================================================="
echo "Auto-AI-Hub Setup Completed!"
echo "-------------------------------------------------------------"
echo "Please save the following information somewhere securely:"
echo "AI-Hub Hostname: ${PREFIXHOSTNAME}-${UniqueHostname}.local"
echo "AI-Hub IP Address: $FunctionalAddress"
echo "AI-Hub login/password:  admin/${ADMINPASSWORD}"
echo "Please wait 5-10 minutes for the system to fully startup"
echo "-------------------------------------------------------------"
echo "YOU WILL ALMOST CERTAINLY NEED TO ADD THE FOLLOWING LINE"
echo "OF HOSTNAMES TO YOUR PC/LAPTOP \"HOSTS\" FILE TO USE THE AI-HUB"
echo "-------------------------------------------------------------"
echo "$FunctionalAddress       ${PREFIXHOSTNAME}-${UniqueHostname}.local       ${PREFIXHOSTNAME}-${UniqueHostname}"
echo ""
echo "-------------------------------------------------------------"
echo "When completed, browse to https://${PREFIXHOSTNAME}-${UniqueHostname}.local"
echo "If you need to turn off the AI-Hub or restart the system, use docker compose down"
echo "============================================================="
echo ""
}

#vars
hubversion="2026.1.1"
PREFIXHOSTNAME="auto-ai-hub"
VERBOSE=0
CREDLIC=0
SKIPDOCKER=0
PORTLIC="6200"
HOSTLIC="127.0.0.1"
UniqueHostname=""


#startup reqs
[ $# -eq 0 ] && { $echodocs; exit 1; }
[ "$(whoami)" = root ] || { echo 'You must first become root with sudo su - '; exit 1; }

#check the arguements manually and shift the values to parse them all
for i in "$@"; do
  case $i in
  
    -u=*|--username=*)
      AIHUBUSER="${i#*=}"
      $echolog "${AIHUBUSER}"
      $checkchars "${AIHUBUSER}"
      if [ getent passwd "${AIHUBUSER}" > /dev/null]; then
        $echolog "User ${AIHUBUSER} exists"
      else
        echo "${AIHUBUSER} is not a valid user on this system"
        exit 1
      fi
      shift # past argument=value
      ;;
      
    -p=*|--password=*)
      ADMINPASSWORD="${i#*=}"
      $checkchars "${ADMINPASSWORD}"
      shift # past argument=value
      ;;
      
    -d=*|--directory=*)
      HOMEDIRECTORY="${i#*=}"
      $checkchars "${HOMEDIRECTORY}"
      if [ ! -d "${HOMEDIRECTORY}" ]; then
         echo "Please pick a real directory and use absolute path, not relative."
         exit 1
      fi      
      shift # past argument=value
      ;;
      
    -H=*|--hostname=*)
      HOSTLIC="${i#*=}"
      $checkchars "${HOSTLIC}"
      HOSTLIC=${HOSTLIC//[^a-zA-Z0-9\.]/}
      shift # past argument=value
      ;;
      
    -P=*|--port=*)
      PORTLIC="${i#*=}"
      $checkchars "${PORTLIC}"
      PORTLIC=${PORTLIC//[0-9]/}
      shift # past argument=value
      ;;
      
    -w=*|--webprefix=*)
      PREFIXHOSTNAME="${i#*=}"
      $checkchars "${PREFIXHOSTNAME}"
      HOMEDIRECTORY=${HOMEDIRECTORY//[^a-zA-Z0-9-]/}
      shift # past argument=value
      ;;    
      
    -c|--credentials)
      CREDLIC=1
      shift # past argument=value
      ;;
        
    -s|--skipdocker)
      if ! docker compose version; then
        echo "Docker compose is not installed, you cannot skip this installation"
        exit 1
      fi
      $echolog "Docker Compose is already installed, and user opted to skip reinstalling."
      SKIPDOCKER=1
      shift # past argument=value
      ;;

    -v|--verbose)
      VERBOSE=1
      shift # past argument with no value
      ;;
      
    -h|--help)
      $echodocs
      ;;
      
    --*|-*)
      echo "Unknown option $i"
      exit 1
      ;;

    *)
      echo "Did not understand $i"
      exit 1
      ;;
    
      
  esac
done
$documents
HOMEDIRECTORY="/home/${AIHUBUSER}"
$echolog "Setting up permissions for ${HOMEDIRECTORY} to ${AIHUBUSER}"
chown "${AIHUBUSER}":"${AIHUBUSER}" "${HOMEDIRECTORY}"

#check operating system
OperatingSystem=$(grep '^NAME=' /etc/os-release | cut -f 2 -d '"' | tr '[:lower:]' '[:upper:]')
$echolog "${OperatingSystem} detected"

#execute docker install with case
{ #try
case $OperatingSystem in

  "RED HAT ENTERPRIZE LINUX")
    $echolog "Detected Red Hat operating system"    
    dnf update -y
    dnf upgrade -y
    dnf install -y curl wget vim unzip openssl git haveged
    if [ "${SKIPDOCKER}" = 0 ]; then     
      $echolog "Attempting to install docker"
      dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc
      dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      sed -i 's/rhel/centos/g' /etc/yum.repos.d/docker-ce.repo
      dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
      dnf update -y
      dnf install -y docker-ce docker-ce-cli containerd.io
      $echolog "Installed docker compose on RHEL"
    fi
  ;;

  "ROCKY LINUX")
    $echolog "Detected Rocky operating system"    
    dnf update -y
    dnf upgrade -y
    dnf install -y epel-release
    dnf install -y haveged dnf-utils curl wget vim unzip openssl git --allowerasing        
    if [ "${SKIPDOCKER}" = 0 ]; then     
      $echolog "Attempting to install docker"
      dnf remove -y docker*
      dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      dnf update -y --allowerasing
      dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --allowerasing
      $echolog "Installed docker compose on Rocky Linux"
    fi
  ;;

  "UBUNTU")
    $echolog "Detected Ubuntu operating system"    
    DEBIAN_FRONTEND=noninteractive apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y unzip curl wget vim ca-certificates net-tools gnupg lsb-release haveged openssl git
    if [ "${SKIPDOCKER}" = 0 ]; then 
      $echolog "Attempting to install docker"
      DEBIAN_FRONTEND=noninteractive apt-get remove -y docker docker.io containerd runc
      DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
      curl -kfsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      DEBIAN_FRONTEND=noninteractive apt-get update -y
      DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io
      $echolog "Installed docker compose on Ubuntu"
    fi
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
$echolog "Enabling services"
systemctl enable --now docker
systemctl enable --now haveged
usermod -aG docker "${AIHUBUSER}"

dockerver=$(docker --version | cut -d " " -f 3 | sed 's/,$//')
$echolog "Docker version $dockerver"



#download and install ai-hub via automation

$echolog "Downloading and installing AI-Hub"
$echolog "Downloading ${hubversion} from https://docs.rapidminer.com/assets/download/hub/rapidminer-ai-hub-2026.1.1-docker-compose-template-prod.zip"
wget -P "${HOMEDIRECTORY}" https://docs.rapidminer.com/assets/download/hub/rapidminer-ai-hub-"${hubversion}"-docker-compose-template-prod.zip --output-document="${HOMEDIRECTORY}"/rapidminer-ai-hub-"${hubversion}"-docker-compose-template-prod.zip
$echolog "Extracting data"
unzip -o "${HOMEDIRECTORY}"/rapidminer-ai-hub-"${hubversion}"-docker-compose-template-prod.zip -d "${HOMEDIRECTORY}"
ls "${HOMEDIRECTORY}"/prod
$echolog "Files staged in prod folder"

#timezone set to local maxchine
linuxtimezone=$(timedatectl | grep "Time zone" | tr -s " " | cut -f 4 -d ' ')
sed -i "s%TZ=UTC%TZ=${linuxtimezone}%g" "${HOMEDIRECTORY}"/prod/.env
$echolog "Configured TZ"

#create the cert folder if its not already there
mkdir -p "${HOMEDIRECTORY}"/my-certs
$echolog "Created my-certs"
#check if there is already been a unique id generated to prevent collisions during testing
if [ ! -f "${HOMEDIRECTORY}"/my-certs/UniqueID ]; then
    cat >> "${HOMEDIRECTORY}"/my-certs/UniqueID << 'END'
#UniqueHostnameIdentifier
UniqueHostname=target
END
    UniqueIdentifier=$(tr -dc a-f0-9 </dev/urandom | head -c 6)
    sed -i "s/target/${UniqueIdentifier}/g" "${HOMEDIRECTORY}"/my-certs/UniqueID
    $echolog "Created new Unique Identifier ${UniqueIdentifier}"
fi
#read the source with the unique id and write it into the config
source "${HOMEDIRECTORY}"/my-certs/UniqueID
sed -i "s%PUBLIC_DOMAIN=platform.rapidminer.com%PUBLIC_DOMAIN=${PREFIXHOSTNAME}-${UniqueHostname}.local%g" /home/"${AIHUBUSER}"/prod/.env
sed -i "s%SSO_PUBLIC_DOMAIN=platform.rapidminer.com%SSO_PUBLIC_DOMAIN=${PREFIXHOSTNAME}-${UniqueHostname}.local%g" /home/"${AIHUBUSER}"/prod/.env
$echolog "Configured hostnames"

#generate fresh keycloak secret
$echolog "Generating fresh keycloak secret..."
freshkeycloak="$(echo $RANDOM | md5sum | head -c 20; echo | base64)"
$echolog "$freshkeycloak"
sed -i "s/AUTH_SECRET=\"<AUTH-SECRET-PLACEHOLDER>\"/AUTH_SECRET=\"${freshkeycloak}\"/g" /home/"${AIHUBUSER}"/prod/.env

#generate active mq password
$echolog "Generating ActiveMQ password..."
activemqpassword="$(echo $RANDOM | md5sum | head -c 15)"
$echolog "${activemqpassword}"
sed -i "s/BROKER_ACTIVEMQ_PASSWORD=\"<SERVER-AMQ-PASS-PLACEHOLDER>\"/BROKER_ACTIVEMQ_PASSWORD=${activemqpassword}/g" "${HOMEDIRECTORY}"/prod/.env
sed -i "s/KEYCLOAK_DBPASS=changeit/KEYCLOAK_DBPASS=${ADMINPASSWORD}/g" "${HOMEDIRECTORY}"/prod/.env
$echolog "Platform admin creds configured"
sed -i "s/KC_BOOTSTRAP_ADMIN_PASSWORD=changeit/KC_BOOTSTRAP_ADMIN_PASSWORD=${ADMINPASSWORD}/g" "${HOMEDIRECTORY}"/prod/.env
$echolog "Keycloak database configured"

#create jupyterhub secret
JupyterCryptKey=$(openssl rand -hex 32)
sed -i "s%JUPYTERHUB_CRYPT_KEY=\"<JUPYTERHUB-CRYPT-KEY-PLACEHOLDER>\"%JUPYTERHUB_CRYPT_KEY=""${JupyterCryptKey}""%g" "${HOMEDIRECTORY}"/prod/.env
$echolog "Jupyter Hub secret configured"

#credentials license
if [ "$CREDLIC" -eq 1 ]; then
    echo "Please enter License Unit Manager User Name (email address for Siemens AltairOne):"
    read -r LicenseUser
    echo "Please carefully enter License Unit Manager Password (creds for Siemens AltairOne):"
    read -r -s LicenseUserPasswordfirst
    echo "Please re-enter password:"
    read -r -s LicenseUserPasswordsecond
    if [ "${LicenseUserPasswordfirst}" == "${LicenseUserPasswordsecond}" ]; then
                  echo "Password recorded"
                    LicenseUserPassword=${LicenseUserPasswordfirst}
    else
                    echo "Passwords did not match"
                    exit 1
    fi
    sed -i "s/LICENSE_UNIT_MANAGER_USER_NAME=/LICENSE_UNIT_MANAGER_USER_NAME=${LicenseUser}/g" "${HOMEDIRECTORY}"/prod/.env
    sed -i "s/LICENSE_PROXY_MODE=on_prem/LICENSE_PROXY_MODE=altair_one/g" "${HOMEDIRECTORY}"/prod/.env
    sed -i "s/LICENSE_UNIT_MANAGER_PASSWORD=/LICENSE_UNIT_MANAGER_PASSWORD=${LicenseUserPassword}/g" "${HOMEDIRECTORY}"/prod/.env
else
#on prem license
    $echolog "User did not specify \"creds\" as a command argument, defaulting to prem license server."
    
    LicensePath=""${PORTLIC}"@${HOSTLIC}"
    $echolog "Setting license data to "${PORTLIC}"@${HOSTLIC}"    
    sed -i "s%ALTAIR_LICENSE_PATH=%ALTAIR_LICENSE_PATH=${LicensePath}%g" "${HOMEDIRECTORY}"/prod/.env
fi
#setting machine details
LicenseAgentID="$(openssl rand -hex 4)-$(openssl rand -hex 2)-$(openssl rand -hex 2)-$(openssl rand -hex 2)-$(openssl rand -hex 6)"
$echolog "Machine ID = ${LicenseAgentID}"
sed -i "s/LICENSE_AGENT_MACHINE_ID=\"\"/LICENSE_AGENT_MACHINE_ID=\"${LicenseAgentID}\"/g" "${HOMEDIRECTORY}"/prod/.env
sed -i "s/LICENSE_AGENT_MACHINE_ID=\"00000000-0000-0000-0000-000000000000\"/LICENSE_AGENT_MACHINE_ID=\"${LicenseAgentID}\"/g" "${HOMEDIRECTORY}"/prod/.env
$echolog "License configured"

#1031 Pano mac address creation for altair one licensing
PanoGenMAC=$(cat /dev/urandom | tr -d -c '[:digit:]A-F' | fold -w 12 | sed -E -n -e '/^.[26AE]/s/(..)/\1-/gp' | sed -e 's/-$//g' |sed 's/-/:/g'| head -n1 | sed 's/^\S\S/66/g')
$echolog "Panopticon Generated MAC address = ${PanoGenMAC}"
sed -i "s/PANOPTICON_VIZAPP_CONTAINER_MAC_ADDRESS=\"<PANOPTICON-MAC-ADDRESS-PLACEHOLDER>\"/PANOPTICON_VIZAPP_CONTAINER_MAC_ADDRESS=\"${PanoGenMAC}\"/g" "${HOMEDIRECTORY}"/prod/.env

#custom cert fix
sed -i 's%CUSTOM_CA_CERTS_FILE=.*%CUSTOM_CA_CERTS_FILE=certificate.crt%g' "${HOMEDIRECTORY}"/prod/.env
$echolog "Added custom ca certs file"

#create the ssl directory
mkdir -p "${HOMEDIRECTORY}"/prod/ssl
mkdir -p "${HOMEDIRECTORY}"/prod/panopticon
$echolog "Created pano and ssl directories"
chown -R "${AIHUBUSER}":"${AIHUBUSER}" "${HOMEDIRECTORY}"/prod
chmod -R 750 "${HOMEDIRECTORY}"/prod
chmod a+rw "${HOMEDIRECTORY}"/prod/.env
chown -R 2011:0 "${HOMEDIRECTORY}"/prod/ssl/
chmod -R ug+w "${HOMEDIRECTORY}"/prod/ssl/
chmod -R o-rwx "${HOMEDIRECTORY}"/prod/ssl/
chown -R 2011:0 "${HOMEDIRECTORY}"/prod/panopticon/
chmod -R ug+w "${HOMEDIRECTORY}"/prod/panopticon/
chmod -R o-rwx "${HOMEDIRECTORY}"/prod/panopticon/
$echolog "Finished AI-Hub file staging"

#creating certificate authority
$echolog "Creating cryptography setup"
#collect networking data
MainAdapter=$(route | grep default | tr -s ' ' | cut -f 8 -d ' ')
FunctionalAddress=$(ip addr show "${MainAdapter}" | grep -w inet | awk '{print $2}' | sed "s%\/.*%%g")
$echolog "Network data"
$echolog "${MainAdapter} ${FunctionalAddress}"

#create ca cert and key
CASharedSubject="/C=US/O=RapidMiner/OU=AutoAIHub/CN=${PREFIXHOSTNAME}-${UniqueHostname}.local"
$echolog "Shared Subject is ${CASharedSubject}"
$echolog "Creating self signed root trust key and certificate"
openssl genpkey -out "${HOMEDIRECTORY}"/my-certs/ca-root.key -outform PEM -algorithm RSA -pkeyopt rsa_keygen_bits:4096
$echolog "Created private ca key, now creating ca root certificate"
openssl req -x509 -new -nodes -key "${HOMEDIRECTORY}"/my-certs/ca-root.key -sha256 -days 3650 -subj "${CASharedSubject}" -out "${HOMEDIRECTORY}"/my-certs/ca-root.crt
$echolog "Generating CSR"
openssl req -new -nodes -outform PEM -out "${HOMEDIRECTORY}"/my-certs/server.csr -newkey rsa:4096 -keyout "${HOMEDIRECTORY}"/my-certs/private.key -subj "${CASharedSubject}"

#create ca config
$echolog "Creating ext config"
cat >> "${HOMEDIRECTORY}"/my-certs/server.v3.ext << 'END'
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = <YOUR-SERVER-HOSTNAME>
IP.1 = <YOUR-SERVER-IP-ADDRESS>
END
$echolog "Updating external config to point to ${PREFIXHOSTNAME}-${UniqueHostname}.local at $FunctionalAddress"
sed -i "s%<YOUR-SERVER-HOSTNAME>%${PREFIXHOSTNAME}-${UniqueHostname}.local%g" "${HOMEDIRECTORY}"/my-certs/server.v3.ext
sed -i "s%<YOUR-SERVER-IP-ADDRESS>%$FunctionalAddress%g" "${HOMEDIRECTORY}"/my-certs/server.v3.ext
$echolog "Created ext config:"
if [ $VERBOSE -eq 1 ]; then cat "${HOMEDIRECTORY}"/my-certs/server.v3.ext; fi #debug output
$echolog "Creating server certificate"
openssl x509 -req -in "${HOMEDIRECTORY}"/my-certs/server.csr -inform PEM -CA "${HOMEDIRECTORY}"/my-certs/ca-root.crt -CAform PEM -CAkey "${HOMEDIRECTORY}"/my-certs/ca-root.key -CAkeyform PEM -CAcreateserial -out "${HOMEDIRECTORY}"/my-certs/certificate.crt -outform PEM -days 1095 -sha256 -extfile "${HOMEDIRECTORY}"/my-certs/server.v3.ext 
if [ $VERBOSE -eq 1 ]; then ls -shalt "${HOMEDIRECTORY}"/my-certs/; fi #debug output
$echolog  "Cryptography complete."

#get the latest images
$echolog "Pulling images from repositories"
until su -g docker -c "docker compose -f ${HOMEDIRECTORY}/prod/docker-compose.yml pull"; do echo retrying; done
#run deployment-init to generate backend
$echolog "Starting Auto-AI-Hub deployment-init"
su -g docker -c "docker compose -f ${HOMEDIRECTORY}/prod/docker-compose.yml up -d deployment-init" "${AIHUBUSER}"
su -g docker -c "docker compose -f ${HOMEDIRECTORY}/prod/docker-compose.yml logs -f" "${AIHUBUSER}" | while read -r LOGLINE
do
    $echolog "$LOGLINE"
    [[ "${LOGLINE}" == *"deployment-init-1 exited with code"* ]] && echo "!!!executing changes based on logs!!!" && su -g docker -c "docker compose -f ${HOMEDIRECTORY}/prod/docker-compose.yml down" "${AIHUBUSER}"
done
$echolog "Deployment-init complete."

#move certificates to proper folder
$echolog "Staging Certificates"
cp "${HOMEDIRECTORY}"/my-certs/certificate.crt "${HOMEDIRECTORY}"/prod/ssl/
cp "${HOMEDIRECTORY}"/my-certs/private.key "${HOMEDIRECTORY}"/prod/ssl/
$echolog "Merging root trust"
cat "${HOMEDIRECTORY}"/my-certs/ca-root.crt >> "${HOMEDIRECTORY}"/my-certs/certificate.crt

#run prepare-cust-ca.sh
$echolog "Executing prepare-cust-ca.sh"
cd "${HOMEDIRECTORY}"/prod
bash ./prepare-cust-ca.sh
chown "${AIHUBUSER}":"${AIHUBUSER}" "${HOMEDIRECTORY}"/prod/docker-compose.yml
$echolog "Prepare-cust-ca.sh completed."
$echolog "Starting up AI-Hub"
su -g docker -c "docker compose -f ${HOMEDIRECTORY}/prod/docker-compose.yml up -d" "${AIHUBUSER}"
$echolog "Script complete"
if [ $VERBOSE -eq 1 ]; then docker ps; fi #debug output

#finish script with documentation output
$exitdocs
exit 0
