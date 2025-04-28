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


#encrypt target file with selected fernet.key
def encryptTargetFile(filePathTarget):
  encryptTargetFile = input("Please enter exact target filename to encrypt:")
  print("Encrypting Target File" + filePathTarget)
# opening the key
  with open('fernet.key', 'rb') as filekey:
	key = filekey.read()
# using the generated key
  fernet = Fernet(key)
# opening the original file to encrypt
  with open(filePathTarget, 'rb') as file:
	original = file.read()	
# encrypting the file
  encrypted = fernet.encrypt(original)
# opening the file in write mode and 
# writing the encrypted data
  with open(filePathTarget, 'wb') as encrypted_file:
	encrypted_file.write(encrypted)


#decrypt target file with selected fernet.key
def decryptTargetFile(filePathTarget):
  print("Decrypting Target File" + filePathTarget)
# using the key
  fernet = Fernet(key)
  decrypted = fernet.decrypt(encrypted)
# opening the encrypted file
  with open('nba.csv', 'rb') as enc_file:
	encrypted = enc_file.read()


# opening the file in write mode and
# writing the decrypted data
  with open('nba.csv', 'wb') as dec_file:
	dec_file.write(decrypted)


#select target file to encrypt or decrypt
def checkFilePathTarget(filePathTarget):
  filePathTarget = input("Please enter exact filename:")
  filepath = Path(filePathTarget) 
  if filepath.is_file():
    return filePathTarget
  else:
    print("Not a file.")
    break
    

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
    checkFilePathTarget()
    createFernetKey()
    return "first thing"
  elif fernetMenuSelection.lower() == "l":
    print("Load existing Fernet Key")
    checkFilePathTarget()   
    return "second thing"
  elif fernetMenuSelection.lower() == "e":
    print("(!)Encrypt Target File (!)")
    checkFilePathTarget()
    encryptTargetFile(fernetPathTarget)
    return "third thing"
  elif fernetMenuSelection.lower() == "d":
    print("(!)Decrypt Target File (!)")
    checkFilePathTarget()
    return "foruth thing"
  elif fernetMenuSelection.lower() == "q":
    print("Quitting, goodbye.")
    exit()
  else:
    return "Invalid Selection"
    break

if __name__ == "__main__":
  main()



