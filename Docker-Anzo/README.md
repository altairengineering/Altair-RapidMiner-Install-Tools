# Docker containerized Anzo Graph Lakehouse
## A study and research image
⚠️ Not recommended for production usage ⚠️

Special Thanks To:  
Lloyd L. - developer
Nigesh P. - developer
Boris S. - developer
Oliver C. - tester

### Roadmap
* Add ELK Stack
* Add Distributed Unstructured

### Minimum requirements:
Docker system with 30 GB of RAM.   Ubuntu linux 2404 has been tested.  Docker for Desktop (windows) is untested.

### Installation:

Open ports 8946, 5600, and 5700 on target system.   

Unpack the Docker-Anzo code on your VM or system.  

Then enter these commands:

```
cd docker-anzo
docker compose up -d
```

Connect to 8946 port with a web browser and configure the installation.

### Creating a Lakehouse

Browse to the Admin settings page.
Open the "Connections" menu and select "Altair Graph Lakehouse"
Click "Add new Altair Graph Lakehouse" > "Add new Altair Graph Lakehouse" (not cloud locations)
Add the anzodb information defaults

* Title: Name it what you want
* Host: anzodb
* Admin User: admin
* Admin Password: Passw0rd1
* Query User: admin
* Query Password: Passw0rd1

Then click save!


### Loading Graphmart zipfile

Use docker cp command to stage the zipfile inside the Anzo container

```
docker cp ./graphmart.zip CONTAINERID:/opt/Anzo/shared/data/serverGraphStore
```

