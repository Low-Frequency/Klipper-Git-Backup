#!/bin/bash

echo "Checking for dierectories"

if [[ -d /home/pi/scripts ]]
then
	echo "Scripts folder already exists"
else
	echo "Crating scripts folder"
	mkdir /home/pi/scripts
fi

if [[ -d /home/pi/git_log ]]
then
	echo "Log folder already exists"
else
	echo "Creating log folder"
	mkdir /home/pi/git_log
fi

if [[ -d /home/pi/.ssh ]]
then
	echo "SSH folder already exists"
else
	echo "Creating SSH folder"
	mkdir /home/pi/.ssh
fi

echo "Checking if git is installed"

if ! command -v git &> /dev/null
then
        echo "Git is not installed"
        echo "Installing git"
        sudo apt install git -y
else
        echo "Git already installed"
fi

read -p 'Please enter your GitHub Username: ' USER
read -p 'Please enter the name of your GitHub repository: ' REPO
read -p 'Please enter the e-mail of your GitHub account: ' MAIL

URL="https://github.com/$USER/$REPO"

echo "Checking for GutHub SSH key"

if [[ -f /home/pi/.ssh/github_id_rsa ]]
then
	echo "SSH key already present"

	ADDED=o
	while [[ "$ADDED" != "y" || "$ADDED" != "n" ]]
	do
		read -p 'Did you already add this key to your GitHub account? [y|n] ' ADDED

		case $ADDED in
			n)
				echo "Please add this key to your GitHub account:"
				echo ""
				cat /home/pi/.ssh/github_id_rsa.pub
				echo ""
				echo "You can find instructions for this here:"
			        echo "https://github.com/Low-Frequency/klipper_backup_script"
			        echo ""
				read -p 'Press enter to continue' CONTINUE
				break
				;;
			y)
				echo "Continuing setup"
				break
				;;
			*)
				echo "Please input a valid answer [y|n]"
				;;
		esac
	done
else
	echo "Generating SSH key pair"
	ssh-keygen -t ed25519 -C "$MAIL" -f /home/pi/.ssh/github_id_rsa -q -N ""
	echo "IdentityFile ~/.ssh/github_id_rsa" >> /home/pi/.ssh/config
	chmod 600 /home/pi/.ssh/config

	echo "Please copy the public key and add it to your GitHub account:"
	echo ""
	cat /home/pi/.ssh/github_id_rsa.pub
	echo ""
	echo "You can find instructions for this here:"
	echo "https://github.com/Low-Frequency/klipper_backup_script"
	echo ""
	read -p 'Press enter to continue' CONTINUE
fi

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

echo "Configuring the script"

echo "##" >> /home/pi/scripts/klipper_backup_script/backup.cfg
echo "## Log Rotation enable/disable" >> /home/pi/scripts/klipper_backup_script/backup.cfg
echo "## 1: enable" >> /home/pi/scripts/klipper_backup_script/backup.cfg
echo "## 0: disable" >> /home/pi/scripts/klipper_backup_script/backup.cfg

echo "Do you want to enable log rotation?"
echo "This can save space on your SD card"
echo "Type 1 to enable log rotation"
echo "Type 0 to disable log rotation"

ROT=9999
while [[ $ROT != 1 || $ROT != 0 ]]
do
	read -p 'Enable log rotation? ' ROT

	case $ROT in
		0)
			echo "ROTATION=0" >> /home/pi/scripts/klipper_backup_script/backup.cfg
			echo "Log rotation disabled"
			break
			;;
		1)
                        echo "ROTATION=1" >> /home/pi/scripts/klipper_backup_script/backup.cfg
                        echo "Log rotation enabled"
			break
                        ;;
		*)
			echo "Please provide a valid configuration"
			echo ""
			;;
	esac
done

echo "##" >> /home/pi/scripts/klipper_backup_script/backup.cfg
echo "## Time in months to keep the logs" >> /home/pi/scripts/klipper_backup_script/backup.cfg

if [ $ROT = 0 ]
then
	echo "RETENTION=6" >> /home/pi/scripts/klipper_backup_script/backup.cfg
else
	read -p "How long should the logs be kept (in months) " KEEP
	echo "RETENTION=$KEEP" >> /home/pi/scripts/klipper_backup_script/backup.cfg
fi

echo "Setting up the service"
sudo mv /home/pi/scripts/klipper_backup_script/gitbackup.service /etc/systemd/system/gitbackup.service
sudo chown root:root /etc/systemd/system/gitbackup.service
sudo systemctl enable gitbackup.service
sudo systemctl start gitbackup.service

echo "Testing SSH connention"
ssh -T git@github.com
echo "Pushing the first backup to your repo"
/home/pi/scripts/klipper_backup_script/klipper_config_git_backup.sh
rm /home/pi/setup.sh
