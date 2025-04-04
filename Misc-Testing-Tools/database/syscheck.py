import os
import subprocess
import pandas
import platform

checkStorage = "df -h"
checkMemory = "free -h"
#checkDocker = "docker image list"

print("\nMemory Status")
memoryStatus = subprocess.call(checkMemory, shell=True)
print("\nStorage Status")
storageStatus = subprocess.call(checkStorage, shell=True)
#print("\nDocker Status")
#dockerStatus = subprocess.call(checkDocker, shell=True)
#print("\nScript complete")

# rm_main is a mandatory function, 
# the number of arguments has to be the number of input ports (can be none),
#     or the number of input ports plus one if "use macros" parameter is set
# if you want to use macros, use this instead and check "use macros" parameter:
#def rm_main(data,macros):
def rm_main(att1):
    print('Hello, world!')  



    # output can be found in Log View

    print(platform.python_version())
    print(type(att1))
    print(att1) 
    #your code goes here

    #for example:
    #data2 = pandas.DataFrame([att1,att2])


    # connect 2 output ports to see the results
    return att1

