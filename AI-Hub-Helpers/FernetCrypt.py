#FernetCrypt.py
#by Anthony Kiehl 20250409
#
#documentation
#https://www.geeksforgeeks.org/encrypt-and-decrypt-files-using-python
#
#libraries
import os
import cryptography
from cryptography.fernet import Fernet

#functions



#create new fernet key, offer default name fernet.key
def makeFernetKey(fernetKeyFile = 'fernet.key'):
  print("Fernet Key Creation:" + fernetKeyFile)
# key generation
  key = Fernet.generate_key()

# string the key in a file
  with open(fernetKeyFile, 'wb') as filekey
    filekey.write(key)

#encrypt target file with selected fernet.key
def encryptTargetFile(encryptTargetFile):
  print("Encrypting Target File" + encryptTargetFile)


#decrypt target file with selected fernet.key
def decryptTargetFile(decryptTargetFile):
  print("Decrypting Target File" + decryptTargetFile)
  

#main operations
def main():
  print("FernetCrypt by Anthony Kiehl")
  sleep(1)
  

if __name__ == "__main__":
  main()



