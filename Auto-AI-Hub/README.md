# Auto AI-hub

<img width="444" height="636" alt="Screenshot 2026-06-22 170411" src="https://github.com/user-attachments/assets/4ca6b663-bd5a-41b8-84aa-b6bb808f3a4d" />



## Description
Auto-AI-Hub is an install script for POC AI-Hub installations using auto-generated, root-trusted self-signed certificates.  

Special thanks to Helge H., Sebastian L., and Geetha T.

_*This should never be used in production environments.*_

## Instructions



### Prep
Set the auto-ai-hub.sh executable.
```
cd ./autoaihub
chmod +x auto-ai-hub.sh
```

### Docs
```
Usage: 
 auto-ai-hub.sh <parameters> 
 
Create an AI-Hub automatically. 
 
Options: 
 -u, --username=<username>          MANDATORY. Specify the linux username that will operate the AI-Hub 
 -p, --password=<aihub_password>    MANDATORY. Admin password cannot contain special characters or spaces 
 -d, --directory=<path>             The directory to install into, by default will install to home folder 
 -H, --hostname=<hostname>          This is the hostname to the license server. Defaults to 127.0.0.1 
 -P, --port=<port>                  Network port number for the license server.  Defaults to 6200     
 -w, --webprefix=<string>           Unique webaddress prefix to URL for AI-Hub.  Defaults to auto-ai-hub           
 -c, --credentials                  Prompts user for license login.  Ignores license hostname and port 
 -s, --skipdocker                   Skips the docker installation 
 -v, --verbose                      Run the command with extra output 
 -t, --trace                        Run the command with trace ouput 
 -h, --help                         Displays this help document as output 
Examples: 
auto-ai-hub.sh -u=ingo -p=agoodpassword 
auto-ai-hub.sh -u=john -p=agoodpassword -d=/opt/autoaihub -H=10.0.15.100 -P=6201 
auto-ai-hub.sh --username=ingo --password=agoodpassword --credentials --verbose 


### License
GNU AFFERO GENERAL PUBLIC LICENSE



