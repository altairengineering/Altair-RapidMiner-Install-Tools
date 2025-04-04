#!/bin/bash
[ `whoami` = root ] || { echo 'you must use sudo'; exit 1; }
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
apt-get -y update 
apt-get -y full-upgrade
apt-get -y install vim curl wget gpg gnupg2 software-properties-common apt-transport-https lsb-release ca-certificates
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
apt-get -y update
apt-get -y install postgresql-14
sed -i '/^host/s/ident/md5/' /etc/postgresql/14/main/pg_hba.conf
sed -i '/^local/s/peer/trust/' /etc/postgresql/14/main/pg_hba.conf
systemctl restart postgresql
systemctl enable postgresql
echo "listen_addresses='*' add to /tc/postgresql/14/main/postgresql.conf"
echo "add these lines to /etc/postgresql/14/main/pg_hba.conf"
echo "# IPv4 local connections:"
echo "host    all             all             127.0.0.1/32            scram-sha-256"
echo "host    all             all             0.0.0.0/0                md5"
echo ""
echo "# IPv6 local connections:"
echo "host    all             all             ::1/128                 scram-sha-256"
echo "host    all             all             0.0.0.0/0                md5"
echo "-----------------------------------------"
echo "run these as sudo su - postgres psql"
echo 'CREATE ROLE admin WITH LOGIN SUPERUSER CREATEDB CREATEROLE PASSWORD 'rapidminer';'

