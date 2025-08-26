#!/bin/bash
# Compose Backup
# by Anthony Kiehl
# 20250825


# vars
DockerRootDir=`docker info | grep "Root Dir" | cut -d " " -f 5`

# check for root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
# check for docker compose file relative to this script

if test -f ./docker-compose.yml; then
  echo "docker compose file located"
else
  echo "Needs to be run in the same directory as the target environment's docker compose file."
fi


# use case

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




# echo instructions if none
# echo warnings of high hard drive space usage
# echo warning of deletion of all contents of /var/lib/docker/volumes

# case here for args



# -b = backup docker system to target tarball
# tarball all the relative folders to the compose as well as the entirety of the /var/lib/docker/
# might as well make two tarballs for simplicity sake, append volumes to one of them
# use "docker info" to get the docker install folder

# -r = restore docker system from target tarballs
#  requires target destination directory
#  requires target tarball and for the appended volumes tarball as well
# deletes all of the /var/lib/docker/ directory and places the appended folders tarball contents
# use "docker info" to get the docker install folder

# reminds user to fix permissions
