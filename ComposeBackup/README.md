# ComposeBackup

A tool for a local docker snapshot that can be restored to original working container state.

ComposeBackup
Usage: ./ComposeBackup.sh (-a|-b|-r) [OPTION ARG]
-----------------------------------
\-a
audit: will audit the system to assist in planning and to help prevent overfilled storage drives by showing the drive storage so the administrator can make a decision to proceed or not with the backup.
-----------------------------------
\-b /target/directory/where/to/save/
backup: backs up all files relative to the docker compose, as well as data from Docker backend system and volumes as a (fairly large) tarball.  Please use the absolute path for the output of the tarball.  Expect sizes greater than 10GB.
-----------------------------------
\-r /target/directory/with/tarballs/
restore: **DESTRUCTIVELY RESTORES** your Docker backend system and volumes.  If you restore onto existing system, it will DELETE EVERYTHING in the Docker backend including all volumes, then place the archived contents back into place.  Please use absolute path for the tarball AND PROCEED WITH CAUTION.
-----------------------------------
\-m /target/directory/with/tarballs/
migrate: functions as restore, but does not search for existing docker-file.  Warning: The current working directory will become the docker compose folder.
-----------------------------------
WARNING: This script will clear you local image cache to prevent undesireable behavior from Docker.  You will have to execute docker compose pull or otherwise get your images back onto the system after BOTH backing up and restoring docker systems with this tool.
