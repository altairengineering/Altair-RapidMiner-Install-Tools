#!/bin/bash
#config
hubversion="2026.1.1"
#main
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
echo "Detecting Docker and Docker-Compose versions"
sleep 1
dockerver=$(docker --version | cut -d " " -f 3 | sed 's/,$//')
echo "Detected Docker $dockerver"
sleep 1

composever=$(docker compose version | cut -d " " -f 4 | sed 's/,$//')
echo "Detected Compose $composever"
sleep 1

