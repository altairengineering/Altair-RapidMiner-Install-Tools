#!/bin/bash
# Compose Backup
# by Anthony Kiehl
# 20250825


# vars
# use "docker info" to get the docker install folder
DockerRootDir=`docker info | grep "Root Dir" | cut -d " " -f 5`
TargetTarballFilepath=$2

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

#check for args

## use case here for args


case "$1" in


# -a = audit
# run df -h
# run du on the /var/lib/docker and .
# warn user that this operation can take 30GB of filespace or even more
a)
echo "Linux space allocation"
df -h
echo "Docker system filesize"
du -d 1 -c -h -t 10000000 $DockerRootDir
echo "Docker compose folder filesize"
du -d 1 -c -h .

;;




# -b = backup docker system to target tarball
b)
read -n1 -r -p "Backing up system, press any key to continue or Ctrl-C to cancel."
sleep 1
if [[ -z $2]]; then:
  echo "Backing up a system requires a target tarball.  Please use absolute file path."
  exit 1
fi


# tarball all the relative folders to the compose as well as the entirety of the /var/lib/docker/





# -r = restore docker system from target tarballs
#  requires target destination directory
#  requires target tarball and for the appended volumes tarball as well
# deletes all of the /var/lib/docker/ directory and places the appended folders tarball contents

# echo instructions if none
# echo warnings of high hard drive space usage
# echo warning of deletion of all contents of /var/lib/docker/volumes
#)
echo "ComposeBackup"
    echo "Usage: ./ComposeBackup.sh (-a|-b|-r)"
    echo "-a"
    echo "(a)udit: will audit the system to assist in planning and to prevent overfilled storage drives."
    echo "-b /target/tarball/absolute/path"
    echo "(b)ackup: backs up all files relative to the docker compose, as well as data from Docker backend system and volumes as a (fairly large) tarball.  Please use the absolute path for the output of the tarball.  Expect sizes greater than 10GB."
    echo "-r /target/tarball/absolute/path"
    echo "(r)estore: **DESTRUCTIVELY RESTORES** your Docker backend system and volumes.  If you restore onto existing system, it will DELETE EVERYTHING in the Docker backend including all volumes, then place the archived contents back into place.  Please use absolute path for the tarball."
    exit 1

;;




