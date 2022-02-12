#!/bin/bash

## Opening manual
if [[ "$1" = "-h" || "$1" = "--help" ]]
then
	less "$HOME/scripts/klipper_backup_script/manual"
	exit 1
elif [[ -n "$1" ]]
then
	echo "Try -h, or --help for the manual"
	exit 2
fi

if [[ -d "$HOME/.ssh" ]]
then
        echo "SSH folder already exists"
else
        echo "Creating SSH folder"
        mkdir "$HOME/.ssh"
fi

## Getting necessary information
read -p 'Please enter your GitHub Username: ' USER
read -p 'Please enter the name of your GitHub repository: ' REPO

sed -i "s/^USER=.*/USER=$USER/g" "$HOME/.config/klipper_backup_script/backup.cfg"
sed -i "s/^REPO=.*/REPO=$REPO/g" "$HOME/.config/klipper_backup_script/backup.cfg"

URL="https://github.com/$USER/$REPO"

## Checking SSH keys
echo ""
echo "Checking for GitHub SSH key"

if [[ -f "$HOME/.ssh/github_id_rsa" ]]
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
				cat "$HOME/.ssh/github_id_rsa.pub"
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
	read -p 'Please enter the e-mail of your GitHub account: ' MAIL
	ssh-keygen -t ed25519 -C "$MAIL" -f "$HOME/.ssh/github_id_rsa" -q -N ""
	echo "IdentityFile $HOME/.ssh/github_id_rsa" >> "$HOME/.ssh/config"
	chmod 600 "$HOME/.ssh/config"

	echo "Please copy the public key and add it to your GitHub account:"
	echo ""
	cat "$HOME/.ssh/github_id_rsa.pub"
	echo ""
	echo "You can find instructions for this here:"
	echo "https://github.com/Low-Frequency/klipper_backup_script"
	echo ""
	read -p 'Press enter to continue' CONTINUE
fi

## Initializing repo
echo ""
echo "Initializing repo"
git -C "$HOME/klipper_config" init
git -C "$HOME/klipper_config" remote add origin "$URL"
git -C "$HOME/klipper_config" remote set-url origin git@github.com:"$USER"/"$REPO".git

echo "Setting username"
git config --global user.email "$MAIL"
git config --global user.name "$USER"

## Activating GitHub backup
sed -i 's/^GIT=.*/GIT=1/g' "$HOME/.config/klipper_backup_script/backup.cfg"

echo "GitHub backup has been configured and activated"
