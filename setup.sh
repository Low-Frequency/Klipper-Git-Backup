#!/bin/bash


## Regex for spaces in string
SPACE=" |'"

## Installing git
echo "Checking if git is installed"

if ! command -v git &> /dev/null
then
        echo "Git is not installed"
        echo "Installing git"
        sudo apt install git -y
else
        echo "Git already installed"
fi

echo ""

## Fetching backup script
echo "Cloning backup script"
git -C /home/pi/scripts clone https://github.com/Low-Frequency/klipper_backup_script
chmod +x /home/pi/scripts/klipper_backup_script/klipper_config_git_backup.sh
chmod +x /home/pi/scripts/klipper_backup_script/restore_config.sh
chmod +x /home/pi/scripts/klipper_backup_script/uninstall.sh

## Adding config lines
echo ""
echo "Configuring the script"

## Log rotation config

echo ""
echo "Do you want to enable log rotation?"
echo "This can save space on your SD card"
echo "This is recommended, if you choose to backup to Google Drive"
echo ""

ROT="o"
while [[ "$ROT" != "y" && "$ROT" != "n" ]]
do
	read -p 'Enable log rotation? [y|n] ' ROT

	case $ROT in
		n)
			sed -i 's/ROTATION=1/ROTATION=0/g' /home/pi/scripts/klipper_backup_script/backup.cfg
			echo "Log rotation disabled"
			break
			;;
		y)
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
echo ""

if [[ "$ROT" = "y" ]]
then
	read -p "How long should the logs be kept (in months) " KEEP
	sed -i "s/RETENTION=6/RETENTION=$KEEP/g" /home/pi/scripts/klipper_backup_script/backup.cfg
fi

## Choosing backup locations
echo ""
echo "Which backup locations do you want to enable?"
echo "Type y to enable a backup location"
echo "Type n to disable a backup location"
echo ""

G=9
C=9
while [[ "$G" != "y" && "$G" != "n" ]]
do
	read -p 'Do you want to enable GitHub as a backup location? [y|n] ' G

	case $G in
		n)
			echo "GitHub backup disabled"
			sed -i 's/GIT=1/GIT=0/g' /home/pi/scripts/klipper_backup_script/backup.cfg
			;;
		y)
			echo "GitHub backup enabled"
			;;
		*)
			echo "Please provide a valid configuration"
			echo ""
			;;
	esac
done

echo ""

while [[ "$C" != "y" && "$C" != "n" ]]
do
        read -p 'Do you want to enable Google Drive backup? [y|n] ' C

        case $C in
                n)
                        echo "Google Drive backup disabled"
                        sed -i 's/CLOUD=1/CLOUD=0/g' /home/pi/scripts/klipper_backup_script/backup.cfg
                        ;;
                y)
                        echo "Google Drive backup enabled"
						chmod +x /home/pi/scripts/klipper_backup_script/drive.exp
						chmod +x /home/pi/scripts/klipper_backup_script/delete_remote.exp
                        ;;
                *)
                        echo "Please provide a valid configuration"
                        echo ""
                        ;;
        esac
done

## Creating necessary directories
echo ""
echo "Checking for dierectories"

if [[ -d /home/pi/scripts ]]
then
        echo "Scripts folder already exists"
else
        echo "Crating scripts folder"
        mkdir /home/pi/scripts
fi

if [[ -d /home/pi/backup_log ]]
then
        echo "Log folder already exists"
else
        echo "Creating log folder"
        mkdir /home/pi/backup_log
fi

## GitHub setup
if [ "$G" = "y" ]
then
	if [[ -d /home/pi/.ssh ]]
	then
	        echo "SSH folder already exists"
	else
	        echo "Creating SSH folder"
	        mkdir /home/pi/.ssh
	fi

	## Getting necessary information
	read -p 'Please enter your GitHub Username: ' USER
	read -p 'Please enter the name of your GitHub repository: ' REPO
	read -p 'Please enter the e-mail of your GitHub account: ' MAIL

	sed -i "s/USER=/USER=$USER/g" /home/pi/scripts/klipper_backup_script/backup.cfg
	sed -i "s/REPO=/REPO=$REPO/g" /home/pi/scripts/klipper_backup_script/backup.cfg

	URL="https://github.com/$USER/$REPO"

	## Checking SSH keys
	echo ""
	echo "Checking for GitHub SSH key"

	if [[ -f /home/pi/.ssh/github_id_rsa ]]
	then
		echo "SSH key already present"
		echo ""

		ADDED="o"
		while [[ "$ADDED" != "y" && "$ADDED" != "n" ]]
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
					;;
				y)
					echo "Continuing setup"
					;;
				*)
					echo "Please input a valid answer [y|n]"
					;;
			esac
		done
	else
		## Generating SSH key pair
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

	## Initializing repo
	echo ""
	echo "Initializing repo"
	git -C /home/pi/klipper_config init
	git -C /home/pi/klipper_config remote add origin "$URL"
	git -C /home/pi/klipper_config remote set-url origin git@github.com:"$USER"/"$REPO".git

	echo "Setting username"
	git config --global user.email "$MAIL"
	git config --global user.name "$USER"

fi

echo ""

## Installing dependencies
if [ "$C" = "y" ]
then
	echo "Installing rclone"
	curl https://rclone.org/install.sh | sudo bash
	echo ""
	echo "Installing expect"
	sudo apt install expect -y
	echo ""
	## Remote location setup
	echo "Setting up a remote location for your backup"
	REMNAME="google drive"
	while [[ $REMNAME =~ $SPACE ]]
	do
		read -p 'Please name your remote storage (no spaces allowed): ' REMNAME
	done
	sed -i "s/REMOTE/REMOTE=$REMNAME/g" /home/pi/scripts/klipper_backup_script/backup.cfg
	DIR="some directory"
	echo ""
	## Specifying backup folder
	while [[ $DIR =~ $SPACE ]]
	do
		read -p 'Please specify a folder to backup into (no spaces allowed): ' DIR
	done
	sed -i "s/FOLDER=/FOLDER=$DIR/g" /home/pi/scripts/klipper_backup_script/backup.cfg
	/home/pi/scripts/klipper_backup_script/drive.exp "$REMNAME"
fi

## Enabling automatic backups
echo ""
echo "Setting up the service"
sudo mv /home/pi/scripts/klipper_backup_script/gitbackup.service /etc/systemd/system/gitbackup.service
sudo chown root:root /etc/systemd/system/gitbackup.service
sudo systemctl enable gitbackup.service
sudo systemctl start gitbackup.service

echo ""

## Testing GitHub connection
if [ "$G" = "y" ]
then
	echo "Testing SSH connention"
	ssh -T git@github.com
	echo ""
fi

## Backing up/restoring
NOW="o"
BAK="o"
while [[ "$NOW" != "y" && "$NOW" != "n" ]]
do
	read -p 'Do you want to restore a backup, or do a backup now? [y|n] ' NOW
	case $NOW in
		y)
			echo "b: backup"
			echo "r: restore"
			while [[ "$BAK" != "b" && "$BAK" != "r" ]]
			do
				read -p 'Do you want to restore a backup, or do a backup? [b|r] ' BAK
				case $BAK in
					b)
						ACT=1
						;;
					r)
						ACT=2
						;;
					*)
						echo "Please choose a valid action"
						;;
				esac
			;;
		n)
			echo "Backing up is recommended"
			echo "Don't forget that"
			;;
		*)
			echo "Please choose avalid action"
			;;
	esac
done

case $ACT in
	1)
		echo "Pushing the first backup to your specified backup location(s)"
		/home/pi/scripts/klipper_backup_script/klipper_config_git_backup.sh
		;;
	2)
		echo "Restoring backup"
		/home/pi/scripts/klipper_backup_script/restore_config.sh
		;;
	*)
		echo "Error while backing up/restoring"
		;;
esac

## Deleting now unecessary setup script
rm /home/pi/setup.sh
