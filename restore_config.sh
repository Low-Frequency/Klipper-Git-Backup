#!/bin/bash

ARG=$1
URL=$2

if [[ -z $ARG ]]
then
        echo "Please provide a restore mehtod"
        echo "Valid methods are:"
        echo "new: New install of klipper without a git repo set up"
        echo "restore: Restoring an old configuration into an existing git repo"
        echo ""
        echo "If you choose to restore to a new klipper install, please provide the URL to your git repo"
else
        if [ "$ARG" = "restore" ]
        then
                echo "Restoring old configuration"
                git -C /home/pi/klipper_config fetch -all
                git -C /home/pi/klipper_config reset --hard origin/master
        elif [ "$ARG" = "new" ]
        then
                if [[ -z $URL ]]
                then
                        echo "Cloning from $URL"
                        git -C /home/pi/klipper_config "$URL"
                else
                        echo "Please provide the URL to your git repo"
                fi
        else
                echo "Please provide valid restore method"
        fi
fi
