# ComposeBackup

A tool for a local docker snapshot that can be restored to original working container state.

Need to backup the overlays, volumes, and containers.
There is a wrong way to do this.  The overlays were damaged.   He saved all local images to a tarball,  you can push all existing images into a tarball.   This will clear the overlay cache.   Afterwards you can run docker volume prune.

Get rid of all the temp data in the overlay, and all of the temp data in volumes, only keeping the persistent volumes and images.   Overlays are the parts of the image that never persist when you bring down the container.   If you start a debian container, with a local persistent data volume.  When exec'd into the container, its a full linux environment, with all folders.   Only a few folders are truly persistent and needed, and are meant to be kept.  When you bring down the container, they are kept.  If you have put something into "/tmp" on the container, its not persistent, its gone.  When you bring back up the container, the other folders will be unchanged, but the /tmp and other folders will be gone.

The overlay is the design of the image, made up of all the layers.
Need to be able to target custom docker folders.   Run docker info to get the locations.


get all the images with "docker save"
then drop all the images with "docker system prune"

Only do this while stopped.
Make sure to preserve file permissions with either rsync or special tar flags.
