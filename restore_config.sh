#!/bin/bash

YELLOW='\033[0;33m'
RED='\033[0;31m'
NONE='\033[0m'

echo "Which restoring mode dou you want?"
echo "1: Restore an old config to an existing installation"
echo "2: Restore a config to a new installation"
echo ""

read -p 'Please enter the restore mode [1|2] ' MODE

if [ $MODE = 1 ]
then
        echo -e "${YELLOW}WARNING!${NONE} This will delete your current configuration!"
        read -p 'Continue? [y|n] ' CONTINUE
        if [ "$CONTINUE" = "y" ]
        then
                echo "Restoring old configuration"
                git -C /home/pi/klipper_config fetch --all
                git -C /home/pi/klipper_config reset --hard origin/master
        else
                echo -e "${RED}Restore canceled${NONE}"
        fi
elif [ $MODE = 2 ]
then
        echo "Checking SSH key"
        if [[ -f /home/pi/.ssh/github_id_rsa ]]
        then
                if [[ -d /home/pi/klipper_config/.git ]]
                then
                        echo -e "${RED}ERROR!${NONE} The klipper_config folder is already a git repository"
                        echo "Please use restore mode 1"
                else
                        read -p 'Please provide your GitHub Username: ' USER
                        read -p 'Please provide the name of the repo you want to restore: ' REPO
                        URL="https://github.com/$USER/$REPO"

                        echo "Backing up the default klipper_config folder"
                        mv /home/pi/klipper_config /home/pi/klipper_config_bak

                        echo "Cloning the repo"
                        git -C /home/pi clone "$URL"
                        mv "/home/pi/$REPO" /home/pi/klipper_config

                        read -p 'Do you want to keep the old folder? [y|n] ' DEL
                        if [ "$DEL" = "n" ]
                        then
                                echo "Deleting backup"
                                rm -r /home/pi/klipper_config_bak
                        else
                                echo "Old folder is located at /home/pi/klipper_config_bak"
                        fi
                fi
        else
                echo -e "${RED}ERROR!${NONE} Please set up a SSH key pair"
        fi
fi
