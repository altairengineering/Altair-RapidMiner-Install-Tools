https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.htmlhttps://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#FernetCrypt.py
#by Anthony Kiehl 20250409
#
#documentation
#https://www.geeksforgeeks.org/encrypt-and-decrypt-files-using-python
#
#libraries and prereqs
import os
import pip
import sys
import time
from pathlib import Path
if not 'cryptography' in sys.modules.keys():
  pip.main(['install', 'cryptography'])
import cryptography
from cryptography.fernet import Fernet

#functions
    
#create new fernet key, offer default name fernet.key
def createFernetKey(fernetKeyFile = 'fernet.key'):
  print("Fernet Key Creation:" + fernetKeyFile)
# key generation
  key = Fernet.generate_key()
# string the key in a file
  with open(fernetKeyFile, 'wb') as filekey:
    filekey.write(key)


  
#select target file to encrypt or decrypt
def checkTargetPath(fernetPathTarget):
  fernetPathTarget = input("Please enter exact target filename to encrypt, using absolute filepath:")
  filepath = Path(fernetPathTarget) 
  if filepath.is_file():
    return fernetPathTarget

#check if fernet key exists
#def checkTargetPath():
#  fernetPathTarget = input("Please enter exact target filename:")
#  filepath = Path(fernetPathTarget) 
#  if filepath.is_file():
#    return fernetPathTarget
#  else:
#    print("Error cannot find target file")
#    break
#encrypt target file with selected fernet.key
def encryptTargetFile(fernetPathTarget):
  encryptTargetFile = input("Please enter exact target filename to encrypt:")
  print("Encrypting Target File" + fernetPathTarget)
# opening the key
  with open('fernet.key', 'rb') as filekey:
	key = filekey.read()
# using the generated key
  fernet = Fernet(key)
# opening the original file to encrypt
  with open(fernetPathTarget, 'rb') as file:
	original = file.read()	
# encrypting the file
  encrypted = fernet.encrypt(original)
# opening the file in write mode and 
# writing the encrypted data
  with open(fernetPathTarget, 'wb') as encrypted_file:
	encrypted_file.write(encrypted)


#decrypt target file with selected fernet.key
def decryptTargetFile(fernetPathTarget):
  print("Decrypting Target File" + decryptTargetFile)
# using the key
  fernet = Fernet(key)

# opening the encrypted file
  with open('nba.csv', 'rb') as enc_file:
	encrypted = enc_file.read()

# decrypting the file
  decrypted = fernet.decrypt(encrypted)

# opening the file in write mode and
# writing the decrypted data
  with open('nba.csv', 'wb') as dec_file:
	dec_file.write(decrypted)
  

#main operations
def main():
  print("")
  time.sleep(1)
  fernetMenu = '''FernetCrypt by Anthony Kiehl
  Please Select from the following use-cases:
  c = Create New Fernet Key
  l = Load existing Fernet Key
  e = (!)Encrypt Target File (!)
  d = (!)Decrypt Target File (!) 
  q = Quit
  Make sure you have backups of everything before using this tool!  Better safe than sorry.
  #'''
  print(fernetMenu)
  input(fernetMenuSelection)
  if fernetMenuSelection.lower() == "c":
    print("Create New Fernet Key")
    createFernetKey()
    return "first thing"
  elif fernetMenuSelection.lower() == "l":
    print("Load existing Fernet Key")
    checkTargetPath()
    return "second thing"
  elif fernetMenuSelection.lower() == "e":
    print("(!)Encrypt Target File (!)")
    checkTargetPath()
    encryptTargetFile(fernetPathTarget)
    return "third thing"
  elif fernetMenuSelection.lower() == "d":
    print("(!)Decrypt Target File (!)")
    checkTargetPath()
    return "foruth thing"
  elif fernetMenuSelection.lower() == "q":
    print("Quitting, goodbye.")
    exit()
  else:
    return "Invalid Selection"
    break

if __name__ == "__main__":
  main()



