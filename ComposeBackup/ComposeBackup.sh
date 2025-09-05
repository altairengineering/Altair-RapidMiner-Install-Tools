#!/bin/bash
# Compose Backup
# by Anthony Kiehl
# 20250825


# vars
# use "docker info" to get the docker install folder
DockerRootDir=$(docker info | grep "Root Dir" | cut -d " " -f 5)
TargetFilepath=$2
DockerRunningContainers=$(docker ps -a --format json)


# check for root
if [ "$EUID" -ne 0 ]
  then echo "Please run with root privileges"
  exit 1
fi



if [ -z "$DockerRunningContainers" ]; then
  echo "No running containers detected"
else
  echo "Please do not run script with active, running containers, thank you."
  exit 1
fi

#check for args

## use case here for args


case "$1" in


# -a = audit
# run df -h
# run du on the /var/lib/docker and .
# warn user that this operation can take 30GB of filespace or even more
-a)
echo "Linux space allocation"
df -h
echo "Docker system filesize"
du -d 1 -c -h -t 10000000 "$DockerRootDir"
echo "Docker compose folder filesize"
du -d 1 -c -h .

;;




# -b = backup docker system to target tarball
-b)
if [[ -z $2 ]]; then
  echo "Backing up a system requires a target directory to store many gigabytes."
  exit 1
fi

# check for docker compose file relative to this script
if test -f ./docker-compose.yml; then
  echo "docker compose file located"
else
  echo "Needs to be run in the same directory as the target environment's docker compose file."
  exit 1
fi

 # tarball all the relative folders to the compose as well as the entirety of the /var/lib/docker/
echo "removing downloaded images to prevent orphan danglers"
docker image prune -af
echo "archiving docker system installation folder" && sleep 1
tar --create --gzip --verbose --file="$TargetFilepath"DockerSystem.tar.gz "$DockerRootDir" || \
     { echo "Something went wrong with the compression, exiting now."; exit 1; }
echo "processing hidden .env file" && sleep 1
#mv -vf .env hidden.env
echo "archiving docker compose folder" && sleep 1
tar --create --gzip --exclude="$0" --verbose -f "$TargetFilepath"ComposeFolder.tar.gz . .??* || \
     { echo "Something went wrong with the compression, exiting now."; exit 1; }
echo "PLEASE RESTART THE SYSTEM AFTER CREATING THE BACKUP!!! YOU MUST ALSO USE docker compose pull OR OTHERWISE RE-OBTAIN YOUR LOCAL IMAGES!!!"



;;



# -r = restore docker system from target tarballs
#  requires target destination directory
#  requires target tarball and for the appended volumes tarball as well
# deletes all of the /var/lib/docker/ directory and places the appended folders tarball contents
-r)


if [[ -z $2 ]]; then
  echo "Restoring docker to system requires a target directory that contains both tarballs created by this tool."
  exit 1
fi

# check for docker compose file relative to this script
if test -f ./docker-compose.yml; then
  echo "docker compose file located"
else
  echo "Needs to be run in the same directory as the target environment's docker compose file."
  exit 1
fi


echo "extracting compose folder" && sleep 1
tar --extract --ungzip --same-owner --preserve-permissions --overwrite --exclude="$0" --verbose --file="$TargetFilepath"ComposeFolder.tar.gz || \
     { echo "Something went wrong with the extration, exiting now."; exit 1; }
echo "clearing out existing docker installation" && sleep 1
rm -rf "${DockerRootDir:?}"/* || \
     { echo "The docker root dir variable is empty, please check your docker installation status.  Sorry but I cannot proceed."; exit 1; }
echo "extracting docker system folder" && sleep 1
tar --extract --ungzip --same-owner --preserve-permissions --overwrite --verbose --file="$TargetFilepath"DockerSystem.tar.gz -C "$DockerRootDir" || \
     { echo "Something went wrong with the extration, exiting now."; exit 1; }
echo "restoring hidden .env file" && sleep 1
#mv -vf hidden.env .env
echo "PLEASE RESTART THE SYSTEM AFTER RESTORING A BACKUP!!!  YOU MUST ALSO USE docker compose pull OR OTHERWISE RE-OBTAIN YOUR LOCAL IMAGES!!!"

;;

#migration, does not check for docker compose file
-m)


if [[ -z $2 ]]; then
  echo "Restoring docker to system requires a target directory that contains both tarballs created by this tool."
  exit 1
fi



echo "extracting compose folder" && sleep 1
tar --extract --ungzip --same-owner --preserve-permissions --overwrite --exclude="$0" --verbose --file="$TargetFilepath"ComposeFolder.tar.gz  || \
     { echo "Something went wrong with the extration, exiting now."; exit 1; }
echo "clearing out existing docker installation" && sleep 1
rm -rf "${DockerRootDir:?}"/* || \
     { echo "The docker root dir variable is empty, please check your docker installation status.  Sorry but I cannot proceed."; exit 1; }
echo "extracting docker system folder" && sleep 1
tar --extract --ungzip --same-owner --preserve-permissions --overwrite --verbose --file="$TargetFilepath"DockerSystem.tar.gz -C "$DockerRootDir" || \
     { echo "Something went wrong with the extration, exiting now."; exit 1; }
echo "restoring hidden .env file" && sleep 1
#mv -vf hidden.env .env
echo "PLEASE RESTART THE SYSTEM AFTER RESTORING A BACKUP!!!  YOU MUST ALSO USE \"docker compose pull\" OR OTHERWISE RE-OBTAIN YOUR LOCAL IMAGES!!!""
;;



# echo instructions if none
# echo warnings of high hard drive space usage
# echo warning of deletion of all contents of /var/lib/docker/volumes
*)
echo "ComposeBackup"
    echo "Usage: ./ComposeBackup.sh \(-a|-b|-r|-m\) [OPTION ARG]"
    echo "-----------------------------------"
    echo "-a"
    echo "audit: will audit the system to assist in planning and to help prevent overfilled storage drives by showing the drive storage so the administrator can make a decision to proceed or not with the backup."
    echo "-----------------------------------"
    echo "-b /target/directory/to/save/tarballs/"
    echo "backup: backs up all files relative to the docker compose, as well as data from Docker backend system and volumes as a (fairly large) tarball.  Please use the absolute path for the output of the tarball.  Expect sizes greater than 10GB."
    echo "-----------------------------------"
    echo "-r /target/directory/with/tarballs/"
    echo "restore: **DESTRUCTIVELY RESTORES** your Docker backend system and volumes.  If you restore onto existing system, it will DELETE EVERYTHING in the Docker backend including all volumes, then place the archived contents back into place.  Please use absolute path for the tarball AND PROCEED WITH CAUTION."
    echo "-----------------------------------"
    echo "-m /target/directory/with/tarballs/"
    echo "migrate: functions as restore, but does not search for existing docker-file.  Warning: The current working directory will become the docker compose folder."
    echo "WARNING: This script will clear you local image cache to prevent undesireable behavior from Docker.  You will have to execute docker compose pull or otherwise get your images back onto the system after BOTH backing up and restoring docker systems with this tool."
 
    exit 1

;;
esac
echo "Script complete, exiting."
exit 0
