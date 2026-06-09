#!/bin/bash
#config
graphversion="6_3_0"
#main
[ "$(whoami)" = root ] || { echo 'you must run with sudo'; exit 1; }

#promts:
printf "\n"
echo "Graph Studio install helper"
echo "SIEMENS - Anthony Kiehl"
echo "Version 1.0 - 9/20/22 Initial Release"
echo "Special thanks to Nigesh P. and Lloyd L."
echo "Graph Studio $graphversion"
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

