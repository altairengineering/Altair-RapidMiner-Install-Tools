#libraries
import os

#functions

#Create a salt value
def generate_salt():
  # 128 bit salt value 
  salt = os.urandom(16) 
  return salt


#Store a new password


