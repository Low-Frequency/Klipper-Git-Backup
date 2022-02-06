#!/bin/bash

## Regex for space in string
SPACE=" |'"

sudo apt install expect -y

## Set up remote location
REMNAME="google drive"
while [[ $REMNAME =~ $SPACE ]]
do
        read -p 'Please name your remote storage (no spaces allowed): ' REMNAME
done

echo "This was the input:"
echo "$REMNAME"
