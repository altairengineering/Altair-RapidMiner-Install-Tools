#!/bin/bash
#
# Altair AutoHub.sh
# Anthony Kiehl - Altair.com
#
# v1.0 6/25/2024 - Initial release
#
echo "Welcome to the Autohub"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#main logic
case "$1" in
  start)
    HOSTIPADDRESS=`hostname -I | cut -f 1 -d " "`
    HOSTMACADDRESS=$(ip -o link show enp0s3 | cut -d ' ' -f 20 | sed s/://g | awk '{print toupper($0)}')
    echo "$HOSTMACADDRESS"
    #over-write hostname
    echo "Overwriting Hostnames"
    sed -i "s%PUBLIC_PROTOCOL=.*%PUBLIC_PROTOCOL=http%g" /home/rapidminer/prod/.env
    sed -i "s%PUBLIC_DOMAIN=.*%PUBLIC_DOMAIN=$HOSTIPADDRESS%g" /home/rapidminer/prod/.env
    sed -i "s%SSO_PUBLIC_PROTOCOL=.*%SSO_PUBLIC_PROTOCOL=http%g" /home/rapidminer/prod/.env
    sed -i "s%SSO_PUBLIC_DOMAIN=.*%SSO_PUBLIC_DOMAIN=$HOSTIPADDRESS%g" /home/rapidminer/prod/.env
    sed -i "s%ALTAIR_LICENSE_PATH=.*%ALTAIR_LICENSE_PATH=6200@$HOSTIPADDRESS%g" /home/rapidminer/prod/.env



     #update mac address in license util file
     echo "Updating MAC address"
     perl -0777 -i.original -pe "s/enp0s3\nHostid:.*?\n/enp0s3\nHostid: $HOSTMACADDRESS\n/igs" /usr/local/altair/licensing15.5/hostid_info.txt




    echo "Injecting license files, if any"
    mv /home/rapidminer/*.dat /usr/local/altair/licensing15.5/altair_lic.dat > /dev/null 2>&1 ||
    echo "No license in home"
    mv /home/rapidminer/prod/*.dat /usr/local/altair/licensing15.5/altair_lic.dat > /dev/null 2>&1 || echo "No license in prod"

    echo "Starting AutoHub"
    sleep 2
    echo "Activating LMX Server"
    systemctl restart altairlmxd
    sleep 10
    #initialize aihub
    echo "STARTING"
    docker compose -f /home/rapidminer/prod/docker-compose.yml up -d deployment-init
    echo "DEPLOYMENT HAS EXITED TO NEXT INSTRUCTIONS"
    docker logs -f prod-deployment-init-1 | while read -r LOGLINE
       do
            echo "$LOGLINE"
            [[ "${LOGLINE}" == *"Successfully finished."* ]] && echo "!!!executing changes based on logs!!!" && docker compose -f /home/rapidminer/prod/docker-compose.yml up -d
    done
    echo "Autohub script complete"
    exit 0
  ;;

  stop)
    #stop the autohub
    echo "Shutting down AutoHub"
    # stop docker compose
    /usr/bin/docker compose -f /home/rapidminer/prod/docker-compose.yml down
    # force kill all containers
    /usr/bin/docker stop "$(docker ps -a -q)"
    /usr/bin/docker rm "$(docker ps -a -q)"
    # rotate the logs
    /sbin/logrotate -vf /etc/logrotate.d/*
    echo "AutoHub shutdown"
    exit 0
  ;;


  destroy)
    # destroy autohub
    echo "YOU HAVE SELECTED DESTROY! DID YOU KNOW THAT ALL YOUR DATA WILL BE LOST AND AUTO HUB SET TO FACTORY DEFAULTS?"
    read -rp "Are you sure you want to continue? (type YES in caps to continue)" DESTROYCONFIRM
    if [ "$DESTROYCONFIRM" = "YES" ]; then
    echo "Resetting the Hub to factory settings"
        # destroy the container volumes
        /usr/bin/docker compose -f /home/rapidminer/prod/docker-compose.yml down -v
        # destroy all container images
        /usr/bin/docker system prune -af
        # restore config
        cp -rf /home/rapidminer/prod/restoration/dockertemplate.yml /home/rapidminer/prod/docker-compose.yml
        cp -rf /home/rapidminer/prod/restoration/envtemplate.yml /home/rapidminer/prod/.env
        echo "Exiting"
    exit 0
else
    echo "Did not type YES, goodbye."
        exit 1
fi
  ;;

  *)
    #help file
    echo "Autohub help script - Anthony Kiehl 2024"
    echo "Usage: ./autohub.sh {start|stop|destroy}"
    echo "start - will generate new hub automatically, also restart existing hub"
    echo "stop - will safely bring down the hub     "
    echo "destroy - will remove all data irrevocably"
    exit 1
  ;;
esac
