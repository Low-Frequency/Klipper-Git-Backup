#!/bin/bash

read -p 'Please enter your GitHub Username: ' USER
read -p 'Please enter the name of your GitHub repository: ' REPO
read -p 'Please enter the e-mail of your GitHub account: ' MAIL

URL="https://github.com/$USER/$REPO"

echo "Installing git"
sudo apt install git -y

echo "Crating folders"
mkdir /home/pi/scripts
mkdir /home/pi/git_log
mkdir /home/pi/.ssh

echo "Generating SSH key pair"
ssh-keygen -t ed25519 -C "$MAIL" -f /home/pi/.ssh/github_id_rsa -q -N ""
echo "IdentityFile ~/.ssh/github_id_rsa" >> /home/pi/.ssh/config
chmod 600 /home/pi/.ssh/config

echo "Initializing repo"
git -C /home/pi/klipper_config init
git -C /home/pi/klipper_config remote add origin "$URL"
git -C /home/pi/klipper_config remote set-url origin git@github.com:"$USER"/"$REPO".git

echo "Setting username"
git config --global user.email "$MAIL"
git config --global user.name "$USER"

echo "Cloning backup script"
git -C /home/pi/scripts clone https://github.com/Low-Frequency/klipper_backup_script
chmod +x /home/pi/scripts/klipper_backup_script/klipper_config_git_backup.sh
chmod +x /home/pi/scripts/klipper_backup_script/restore_config.sh
chmod +x /home/pi/scripts/klipper_backup_script/uninstall.sh

echo "Setting up the service"
sudo mv /home/pi/scripts/klipper_backup_script/gitbackup.service /etc/systemd/system/gitbackup.service
sudo chown root:root /etc/systemd/system/gitbackup.service
sudo systemctl enable gitbackup.service
sudo systemctl start gitbackup.service

echo "Almost done"
echo "Please copy the public key and add it to your GitHub account"
echo "You can find instructions for this here:"
echo "https://github.com/Low-Frequency/klipper_backup_script"
echo ""
echo ""
cat /home/pi/.ssh/github_id_rsa.pub
echo ""
echo ""

read -p "When you're done, press enter to continue " CONTINUE
echo "Testing SSH connention"
ssh -T git@github.com
echo "Pushing the first backup to your repo"
/home/pi/scripts/klipper_backup_script/klipper_config_git_backup.sh
rm /home/pi/setup.sh
