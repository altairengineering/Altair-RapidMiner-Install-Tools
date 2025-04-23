#FernetCrypt.py
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
def makeFernetKey(fernetKeyFile = 'fernet.key'):
  print("Fernet Key Creation:" + fernetKeyFile)
# key generation
  key = Fernet.generate_key()
  

# string the key in a file
  with open(fernetKeyFile, 'wb') as filekey:
    filekey.write(key)

#encrypt target file with selected fernet.key
def encryptTargetFile(encryptTargetFile):
  encryptTargetFile = input("Please enter exact target filename to encrypt:")
  print("Encrypting Target File" + encryptTargetFile)
  
#select target file to encrypt or decrypt
def checkTargetPath(fernetPathTarget):
  fernetPathTarget = input("Please enter exact target filename to encrypt, using absolute filepath:")
  filepath = Path(fernetPathTarget) 
  if filepath.is_file():
    return fernetPathTarget

#check if fernet key exists
def checkTargetPath(fernetPathTarget):
  fernetPathTarget = input("Please enter exact target filename to encrypt, using absolute filepath:")
  filepath = Path(fernetPathTarget) 
  if filepath.is_file():
    return fernetPathTarget

#decrypt target file with selected fernet.key
def decryptTargetFile(decryptTargetFile):
  print("Decrypting Target File" + decryptTargetFile)
  

#main operations
def main():
  print("")
  time.sleep(1)
  fernetMenu = '''FernetCrypt by Anthony Kiehl
  Please Select from the following use-cases:
  a = Create New Fernet Key
  b = Load existing Fernet Key
  c = (!)Encrypt Target File (!)
  d = (!)Decrypt Target File (!) 
  Make sure you have backups of everything before using this tool!  Better safe than sorry.
  #'''
  input(fernetMenuSelection)
for case in switch(fernetMenuSelection.lower()):
    if case('a'):
        print("Create New Fernet Key")
        break
    if case('b'):
        print("Load existing Fernet Key")
        break
    if case('c'):
        print("(!)Encrypt Target File (!)")
        break
    if case('d'):
        print("(!)Decrypt Target File (!)")
        break
    if case(): # default, could also just omit condition or 'if True'
        print("something else!")
  if something:
    print("Create New Fernet Key")
    return "first thing"
  elif somethingelse:
    return "second thing"
  elif yetanotherthing:
    return "third thing"
  else:
    return "default thing"

if __name__ == "__main__":
  main()



