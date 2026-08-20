#!/bin/bash
#set -o errexit -o pipefail -o noclobber -o nounset -o posix

#VARIABLES
hubversion="2026.1.1"



#FUNCTIONS
#DOCUMENTATION
declare documents='startsplash'
function startsplash () {
#welcome banner
printf "\n"
echo "MigrateDocker Script"
echo "SIEMENS - Anthony Kiehl"
echo "Version 0.1 - 8/11/26 alpha"
echo "Special thanks to: Helge H, Zhanna A"
echo "License: AGPL 3.0 or better"
echo "======================================================================"
sleep 1
}

declare echodocs='helpfile'
function helpfile () {
      echo ''
      echo 'Usage:'
      echo 'migratedocker.sh <parameters>'
      echo ''
      echo 'Import/Export a stateful docker environment automatically.'
      echo ''
      echo 'Options:'
      echo ' -m, --mode=export                  Saves entire docker setup on current machine. Mode export must specify a filename for the tarball to be created with (-f|--file)'
      echo ' -m, --mode=import                  Loads entire docker setup on current machine. WARNING: OVERWRITES EXISTING DOCKER SETUP DESTRICTIVELY.'
      echo ' -f, --file=/path/to/tarball        Always an absolute filepath to a tarball, export mode creates a new file, import mode requires existing file'
      echo ' -c, --compose=/path/to/composefile Target docker compose directory and subfolders, export archives, import writes folder to path (Optional)'
      echo ' -s, --system=/var/lib/docker       Target root docker systems folder (Defaults to /var/lib/docker)'
      echo ' -v, --verbose                      Run the command with extra output'
      echo ' -h, --help                         Displays this help document as output'
      echo 'Examples:'
      echo 'migratedocker.sh -u=ingo -p=agoodpassword'
}

#exit documentation
declare exitdocs='endfile'
function endfile () {
echo ""
echo "============================================================="
echo "MigrateDocker tasks Completed!"
echo "-------------------------------------------------------------"
echo "Please save the following information somewhere securely:"
echo "============================================================="
echo ""
}

#standard logging function
declare echolog='logverbose'
function logverbose () { 
if [ "${TRACE}" -eq 1 ]; then set; printf "===================================\n"; fi 
if [ "${VERBOSE}" -eq 1 ]; then echo "$@"; printf "\n"; fi 
sleep 1
}

#END OF FUNCTIONS


#SYSTEM AUDITS
#startup reqs
[ $# -eq 0 ] && { $echodocs; exit 1; }
[ "$(whoami)" = root ] || { echo 'You must first become root with sudo su - '; exit 1; }


#PARAMETER PARSING
#check the arguements manually and shift the values to parse them all
for i in "$@"; do
  case $i in
  
    -m=*|--mode=*)
      if [[ "${i#*=}" =~ ^(import|export)$ ]]; then
        echo "the only allowed entries for mode are \"import\" or \"export\" without quotes"
        exit 1
      else
      OPERATIONMODE="${i#*=}"
      fi
        shift # past argument=value
      ;;
      
    -p=*|--password=*)
      if [[ "${i#*=}" =~ ^[a-zA-Z][a-zA-Z0-9_.-]*$ ]]; then
        ADMINPASSWORD="${i#*=}"
      else
        echo 'For the passphrase you are only allowed to use basic characters a-zA-Z0-9 _ . -'
        exit 1
      fi
      shift # past argument=value
      ;;
      
    -d=*|--directory=*)
      HOMEDIRECTORY="${i#*=}"
      if [ ! -d "${HOMEDIRECTORY}" ]; then
         echo "Please pick a real directory and use absolute path, not relative."
         exit 1
      fi      
      shift # past argument=value
      ;;
      
    -H=*|--hostname=*)

      if [[ "${i#*=}" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
        HOSTLIC="${i#*=}"
      else
        echo 'For the license hostname you are only allowed to use basic characters a-z A-Z 0-9 _ . -'
        exit 1
      fi
      shift # past argument=value
      ;;
      
    -P=*|--port=*)

      if [[ "${i#*=}" =~ ^[0-9]+$ ]]; then
        PORTLIC="${i#*=}"
      else
        echo 'For the port number you are only allowed to use numbers'
        exit 1
      fi
      shift # past argument=value
      ;;
      
    -w=*|--webprefix=*)

      if [[ "${i#*=}" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
      PREFIXHOSTNAME="${i#*=}"
      else
        echo 'For the hostname prefix you are only allowed to use basic characters a-z A-Z 0-9 . -'
        exit 1
      fi
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

    -t|--trace)
      TRACE=1
      shift # past argument with no value
      ;;
      
    -h|--help)
      $echodocs
      exit 0
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

#MAIN LOGIC
#validate parameters
if [[ -z  "${AIHUBUSER}" || -z "${ADMINPASSWORD}" ]]; then
  echo "ERROR: -u|--username and -p|--password are mandatory arguements."
  exit 1;
fi
if [[ -z "${HOMEDIRECTORY}" ]]; then
  HOMEDIRECTORY="/home/${AIHUBUSER}"
fi






#show starting banner
$documents
if [[ "${VERBOSE}" -eq 0 ]]; then
  echo "Starting Silent install.  Use -v|--verbose to view detailed output."
fi


#EXIT DOCUMENTATION
$exitdocs
exit 0
