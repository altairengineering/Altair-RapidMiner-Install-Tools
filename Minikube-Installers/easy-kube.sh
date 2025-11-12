#!/bin/bash
# Easy Kube 
# by anthony kiehl
# 20251110


#test for docker
command -v docker >/dev/null 2>&1 || { echo >&2 "Docker is required, but it is not installed."; exit 1; }

dockerver=`docker --version | cut -d " " -f 3 | sed 's/,$//'`
echo "Detected Docker $dockerver"
sleep 1

echo "Test for debian family"
if $(cat /proc/version | grep -qEi 'ubuntu|debian'); then
echo "Found debian family, installing"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb

else
echo "Checking next distro"
fi
sleep 1
echo "Test for rhel family"
if $(cat /proc/version | grep -qEi 'red hat|rocky'); then
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
sudo rpm -Uvh minikube-latest.x86_64.rpm
else
#binary install
echo "Defaulting to binary installer"
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
fi
sleep 1
echo "configuring minikube for docker"
minikube config set driver docker
echo "Install complete"
exit 0






