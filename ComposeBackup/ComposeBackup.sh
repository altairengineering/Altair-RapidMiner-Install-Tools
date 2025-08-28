#!/bin/bash
# Compose Backup
# by Anthony Kiehl
# 20250825


# vars
# use "docker info" to get the docker install folder
DockerRootDir=$(docker info | grep "Root Dir" | cut -d " " -f 5)
TargetFilepath=$2
DockerRunningContainers=$(docker info | grep 'Containers' | cut -d " " -f 3)


# check for root
if [ "$EUID" -ne 0 ]
  then echo "Please run with root privileges"
  exit 1
fi
# check for docker compose file relative to this script

if test -f ./docker-compose.yml; then
  echo "docker compose file located"
else
  echo "Needs to be run in the same directory as the target environment's docker compose file."
  exit 1
fi

if [ "$DockerRunningContainers" -gt 0 ]; then
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

 # tarball all the relative folders to the compose as well as the entirety of the /var/lib/docker/

tar --extract --compress --verbose --file="$TargetFilepath"DockerSystem.tar.gz "$DockerRootDir"/*
tar --extract --compress --exclude="$BASH_SOURCE" --verbose --file="$TargetFilepath"ComposeFolder.tar.gz ./*


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

tar --extract --uncompress --same-owner --preserve-permissions --overwrite --exclude="$BASH_SOURCE" --verbose --file="$TargetFilepath"ComposeFolder.tar.gz
tar --extract --uncompress --same-owner --preserve-permissions --overwrite --verbose --file="$TargetFilepath"DockerSystem.tar.gz -C /var/lib


;;


# echo instructions if none
# echo warnings of high hard drive space usage
# echo warning of deletion of all contents of /var/lib/docker/volumes
*)
echo "ComposeBackup"
    echo "Usage: ./ComposeBackup.sh (-a|-b|-r) [OPTION ARG]"
    echo "-----------------------------------"
    echo "-a"
    echo "audit: Audits the system to assist in planning and to help prevent overfilled storage drives by showing the drive storage status.  This only helps the administrator can make a decision to proceed or not with the backup, based on available storage."
    echo "-----------------------------------"
    echo "-b /target/directory/where/to/save/"
    echo "backup: Backs up all files relative to the docker compose, as well as data from Docker backend system and volumes as a (fairly large) tarball.  Please use the absolute path for the output of the tarball.  Expect sizes greater than 10GB."
    echo "-----------------------------------"    
    echo "-r /target/directory/with/tarballs/"
    echo "restore: **DESTRUCTIVELY RESTORES** your Docker backend system and volumes.  If you restore onto existing system, it will DELETE EVERYTHING in the Docker backend including all volumes, then place the archived contents back into place.  Please use absolute path for the tarball AND PROCEED WITH CAUTION."
    exit 1

;;
esac
exit 0
