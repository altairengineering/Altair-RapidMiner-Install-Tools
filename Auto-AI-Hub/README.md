# Auto AI-hub

## Description
Auto-AI-Hub is an install script for POC AI-Hub installations using auto-generated self-signed certificates.  

Special thanks to Sebastian L., and Geetha T.

_*This should never be used in production environments.*_

## Instructions

Notes:  
Where it is listed [username] this refers to the linux username on the target RHEL, Rocky or Ubuntu server.
And where it is written [version], this is the desired AI-Hub version.

### Clone the repo
Auto-AI-Hub requires the scripts located in other parts of the repository.
```
cd ~
git clone https://github.com/altairengineering/Altair-RapidMiner-Install-Tools.git
```

### Prepare for installation
Create symlink to allow easy access to software.
```
cd ~
ln -s /home/[username]/Altair-RapidMiner-Install-Tools/Auto-AI-Hub/ autoaihub
```
Set the auto-ai-hub_setup.sh executable.
```
cd ./autoaihub
chmod +x 
```

### Installation
Now run the script for on-prem license server.
```
sudo ./auto-ai-hub_setup[version].sh [username]
```
Or alternatively, for online credentials validation.
```
sudo ./auto-ai-hub_setup[version].sh [username] creds
```


### Startup
Run the auto-ai-hub_start.sh script, carefully review the output.
```
./auto-ai-hub_start.sh
```

<img width="444" height="636" alt="Screenshot 2026-06-22 170411" src="https://github.com/user-attachments/assets/4ca6b663-bd5a-41b8-84aa-b6bb808f3a4d" />



