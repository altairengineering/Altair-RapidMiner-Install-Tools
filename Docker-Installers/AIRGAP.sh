#!/bin/bash
#AIRGAP Docker Installer
# (c) 2025 Altair
# By Anthony Kiehl
# 20250321: 1.0 Initial Release

[ $# -eq 0 ] && { echo "Usage: $0 username"; exit 1; }

[ `whoami` = root ] || { echo 'you must be root'; exit 1; }


echo "Please enter which distro of linux you would like docker install notes:"
echo "A = Debian"
echo "B = RHEL"
echo "C = Rocky"
echo "D = Ubuntu"

read -r LinuxDistro
LinuxDistro=$(echo "${LinuxDistro}" | tr a-z A-Z)
echo ""	
echo "Ok great.  Now we need to download the packages we will need to install docker.  You can download them from the internet and I recommend pkgs.org for all of the various distros."
sleep 1
echo "Here are the packages we need to install using tools like DPKG or RPM."
sleep 1
echo "Some of these packages may have additional dependancies, and this may end up being a non-trivial task to download and install all of them."
echo ""
echo "https://pkgs.org/search/?q=unzip"
echo "https://pkgs.org/search/?q=wget"  
echo "https://pkgs.org/search/?q=ca-certificates" 
echo "https://pkgs.org/search/?q=gnupg" 
echo "https://pkgs.org/search/?q=lsb-release"
echo "https://pkgs.org/search/?q=haveged"
sleep 1
read -p "Press enter to continue"


	case $LinuxDistro in
	"A")
echo "Begin Debian dry run installer"
sleep 1
echo "Run this command: sed -i '/cdrom/d' /etc/apt/sources.list"
echo "Run this command: DEBIAN_FRONTEND=noninteractive apt-get remove -y docker docker.io containerd runc"
echo "Run this command: echo \"set nocompatible\" > /root/.exrc"
echo "Run this command: echo \"set nocompatible\" > /home/$1/.exrc"
    ;;
#case ends

	"B")
echo "Begin RHEL dry run installer"
sleep 1
echo "Run this command: yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc"
    ;;
#case ends

	"C")
echo "Begin Rocky dry run installer"
sleep 1
echo "Run this command: dnf remove -y docker*"
    ;;
#case ends


	"D")
echo "Begin Ubuntu dry run installer"
sleep 1
echo "Run this command: DEBIAN_FRONTEND=noninteractive apt-get remove -y docker docker.io containerd runc"
    ;;
	#case ends
esac
sleep 1
read -p "Press enter to continue"

echo "Now lets do the follow up actions, which are the same for all distros:"
sleep 1
echo "Again, install the following packages using DPKG or RPM"
sleep 1
echo "https://pkgs.org/search/?q=docker-ce" 
echo "https://pkgs.org/search/?q=docker-ce-cli" 
echo "https://pkgs.org/search/?q=containerd.io"
sleep 1
echo "Run this command: systemctl start docker"
echo "Run this command: systemctl enable docker"
echo "Run this command: systemctl start haveged"
echo "Run this command: systemctl enable haveged"
echo "Run this command: usermod -aG docker $1"
echo "Run this command: docker compose version"
echo "Run this command: docker container run hello-world"
sleep 1
read -p "Press enter to continue"
echo "Thanks all done!"
exit 0





