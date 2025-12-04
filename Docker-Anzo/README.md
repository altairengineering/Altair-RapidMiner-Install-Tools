# Docker containerized Anzo Graph Lakehouse
## A study and research image
⚠️ Not recommended for production usage ⚠️

### Minimum requirements:
Docker system with 30 GB of RAM.   Ubuntu linux 2404 has been tested.  Docker for Desktop (windows) is untested.

### Installation:

Unpack the Docker-Anzo code on your VM or system.  

```
cd docker-anzo
docker compose up -d
```

Open ports 8946 on target system.   

Connect to that port with a web browser and configure the installation.

### Loading Graphmart zipfile

Use docker cp command to stage the zipfile inside the Anzo container

```
docker cp ./graphmart.zip CONTAINERID:/opt/Anzo/shared/data/serverGraphStore
```

