#!/bin/bash

cd Docker_images/
directory=`pwd`
ls | grep tar > files.txt
c=0
printf "START \n"
input="$directory/files.txt"
while IFS= read -r line
do
     c=$((c+1))
     printf "$c) $line \n"
     docker load -i $line
     printf "$c) Successfully created the Docker image $line  \n \n"
done < "$input"
