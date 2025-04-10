#FernetCrypt.py
#by Anthony Kiehl 20250409
#
#documentation
#https://www.geeksforgeeks.org/encrypt-and-decrypt-files-using-python
#
#libraries
import cryptography
from cryptography.fernet import Fernet

#functions



#create new fernet key, offer default name fernet.key
def makeFernetKey():
  print("Fernet Key Creation:")
# key generation
  key = Fernet.generate_key()

# string the key in a file
  with open('fernet.key', 'wb') as filekey
    filekey.write(key)

#encrypt target file with selected fernet.key
def encryptTargetFile():
  print("Encrypting Target File")


#decrypt target file with selected fernet.key
def decryptTargetFile():
  print("Decrypting Target File")
  

#main operations
def main():
  print("FernetCrypt by Anthony Kiehl")


if __name__ == "__main__":
  main()



