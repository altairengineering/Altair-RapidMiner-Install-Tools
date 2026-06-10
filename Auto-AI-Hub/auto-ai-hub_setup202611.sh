#!/bin/bash
#config
hubversion="2026.1.1"
#main
[ $# -eq 0 ] && { echo "Usage: $0 username"; exit 1; }
[ "$(whoami)" = root ] || { echo 'you must run with sudo'; exit 1; }


#promts:
printf "\n"
echo "Auto-AI-Hub Setup script"
echo "SIEMENS - Anthony Kiehl"
echo "Version 1.0 - 6/9/26 Initial Release"
echo "Special thanks to Sebastian L., Lloyd L., and Nigesh P."
echo "Auto-AI-hub version $hubversion"
echo "======================================================================"
sleep 1
echo "Checking installation path"
sleep 1
if [ -e "../README.md"]; then
  echo "Repository readme file present"
else
  echo "Repository readme file not present"
  echo "Please install entire repo using git command:"
  echo "git clone https://github.com/altairengineering/Altair-RapidMiner-Install-Tools.git"
  echo "bye"
  exit 1
fi
echo "Detecting Docker version"
sleep 1
docker --version
if [ $? -eq 127 ]; then
echo "Docker command not detected on path"

#check operating system
OperatingSystem=$(cat /etc/os-release | grep '^NAME=' | cut -f 2 -d '"' | tr a-z A-Z)
echo "$OperatingSystem detected"
sleep 1
echo "Attempting to install docker"
#execute docker installer scripts with case
case $OperatingSystem in

  "RED HAT ENTERPRISE LINUX")
    echo "Detected Red Hat operating system"
    chmod +x ../Docker-Installers/rhel.sh $1
    { #try
    /bin/bash ../Docker-Installers/rhel.sh
    } || { #catch
    echo "RHEL Docker installer failed"
    exit 1}
  ;;

  "ROCKY LINUX")
    echo "Detected Rocky operating system"
    chmod +x ../Docker-Installers/rocky.sh $1
    { #try
    /bin/bash ../Docker-Installers/rhel.sh
    } || { #catch
    echo "RHEL Docker installer failed"
    exit 1}
  ;;

  "UBUNTU")
    echo "Detected Ubuntu operating system"
    chmod +x ../Docker-Installers/ubuntu.sh $1
    { #try
    /bin/bash ../Docker-Installers/rhel.sh
    } || { #catch
    echo "RHEL Docker installer failed"
    exit 1}  
  ;;   

  *)
    echo "Non-supported operating system detected, please contact administrator."
    exit 1
  ;;
  
esac
dockerver=$(docker --version | cut -d " " -f 3 | sed 's/,$//')

}  
sleep 1


#install ai-hub via automation


