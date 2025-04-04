# Autohub


Autohub is a low-touch packaging of the Altair AI-Hub that is designed primarily for academic and school settings.
With Autohub, school should be able to set up AI-Hubs for their students much easier than presently.



## PREREQUISITES


Oracle Virtual Box

WinSCP



## CREDENTIALS


Autohub SSH Login

user: rapidminer

password: * * * * * *

Zip archive

password: * * * * * * 

AI-Hub web login:

user: admin

password: * * * * * *



## INSTRUCTIONS

### VM Setup

1. Install Oracle VM Virtualbox.

2. Extract the autohub VM files using the Zip archive password.

3. Press the "+" Add button and import the file from the archive.

4. Right click the new VM and click Settings.

5. Under System, configure appropriate number of CPUs and amount of RAM

### Bridge settings

6. Under Network, check the Adapter 1 tab, in the "Attached to" setting, set this to "Bridged Adaptor".

7. On the same page, under Name setting, select your active internet adaptor that the computer uses.  Press Ok.

### First boot

8. Start up the virtual machine and view the monitor/KVM to track progress.

9. When the Autohub is done booting, it will display the MAC address as well as the IP Address of the Autohub VM.

10. Contact your Altair Representative with the MAC address to acquire your special academic license file.

11. When you receive this file, use WinSCP or similar tool to upload the file to your Autohub's home folder:
/home/rapidminer/

12. When you are ready to start, from the /home/rapidminer/ folder, enter this command:
sudo ./autohub.sh start

13. Wait 30 minutes for the automation to complete all the tasks and create all the databases.

14. Browse to the IP Address of the autohub with a web browser. Login using the AI-Hub web login.



## TROUBLESHOOTING


ALWAYS BACKUP YOUR DATA, THE AUTOHUB ONLY HAS STATELESS SUPPORT FOR RESETS. 
THAT MEANS YOU COULD LOSE YOUR DATA!

If the autohub starts to have issues, cannot start, or is crashing:

1. Stop the autohub with:
sudo ./autohub stop
1. Restart the VM
2. Log in and run 
sudo ./autohub.sh start

If this fails, the admin must wipe the autohub:

WARNING THIS DELETES ALL AI-HUB DATA

1. Stop the autohub with:
sudo ./autohub destroy
Then at the prompt type YES
2. Wait for the autohub to complete it's process of removal.
3. Restart VM.
4. Run
sudo ./autohub start
5. As before wait patiently for the startup.



## AUTHOR


Anthony Kiehl

akiehl@altair.com