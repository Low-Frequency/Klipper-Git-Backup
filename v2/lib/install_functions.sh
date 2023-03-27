#!/bin/bash

get_input() {
  TEXT="$1"
  read -p "$1 " INPUT
  echo "$INPUT"
}

check_yn() {
  ANSWER=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  case $ANSWER in
    y|n|yes|no)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

check_no() {
  ANSWER=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  case $ANSWER in
    n|no)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

check_int() {
  ANSWER=$1
  case $ANSWER in
    [0-9])
      return 0 ;;
    *)
      return 1 ;;
  esac
}

print_msg() {
  COLOR=$1
  MSG=$2
  case $COLOR in
    purple)
      echo -e "${PURPLE}${MSG}${NC}" ;;
    green)
      echo -e "${GREEN}${MSG}${NC}" ;;
    red)
      echo -e "${RED}${MSG}${NC}" ;;
    cyan)
      echo -e "${CYAN}${MSG}${NC}" ;;
		yellow)
			echo -e "${YELLOW}${MSG}${NC}" ;;
		none)
			echo -e "${NC}${MSG}${NC}" ;;
  esac
}

get_config() {
	print_msg cyan "### Current configuration ###"
	if [[ $GIT -eq 1 ]]
	then
		print_msg green "Backups are enabled"
		print_msg none "GITHUB_USER: ${GITHUB_USER}"
		print_msg none "GITHUB_MAIL: ${GITHUB_MAIL}"
		print_msg none "GITHUB_BRANCH: ${GITHUB_BRANCH}"
		for (( i=0; i<${REPO_COUNT}; i++ ))
		do
			print_msg none "Repository ${i}: ${REPO_LIST[$i]}"
			print_msg none "Config folder ${i}: ${CONFIG_FOLDER_LIST[$i]}"
		done
	else
		print_msg red "Backups are disabled"
	fi
	if [[ $LOG_ROTATION -eq 1 ]]
	then
		print_msg green "Log rotation is enabled"
		print_msg none "LOG_RETENTION=${LOG_RETENTION}"
	else
		print_msg red "Log rotation is disabled"
	fi
	echo -e "\n"
	if [[ $SCHEDULED_BACKUPS -eq 1 ]]
	then
		print_msg green "Scheduled Backups are enabled"
		print_msg none "TIME_UNIT=${TIME_UNIT}"
		print_msg none "BACKUP_INTERVAL=${BACKUP_INTERVAL}"
	else
		print_msg red "Scheduled backups are disabled"
	fi
	CONTINUE=$(get_input "Press enter to continue")
}

save_config() {
	mkdir -p "$HOME/.config/klipper_backup_script"
	if [[ -f "$HOME/.config/klipper_backup_script/backup.cfg" ]]
	then
  	rm "$HOME/.config/klipper_backup_script/backup.cfg"
	fi
	echo "GIT=${GIT}" >> "$HOME/.config/klipper_backup_script/backup.cfg"
	echo "GITHUB_USER=${GITHUB_USER}" >> "$HOME/.config/klipper_backup_script/backup.cfg"
	echo "GITHUB_MAIL=${GITHUB_MAIL}" >> "$HOME/.config/klipper_backup_script/backup.cfg"
	echo "GITHUB_BRANCH=${GITHUB_BRANCH}" >> "$HOME/.config/klipper_backup_script/backup.cfg"
	echo "REPO_LIST=(${REPO_LIST[@]})" >> "$HOME/.config/klipper_backup_script/backup.cfg"
	echo "CONFIG_FOLDER_LIST=(${CONFIG_FOLDER_LIST[@]})" >> "$HOME/.config/klipper_backup_script/backup.cfg"
	echo "LOG_ROTATION=${LOG_ROTATION}" >> "$HOME/.config/klipper_backup_script/backup.cfg"
	echo "LOG_RETENTION=${LOG_RETENTION}" >> "$HOME/.config/klipper_backup_script/backup.cfg"
	echo "SCHEDULED_BACKUPS=${SCHEDULED_BACKUPS}" >> "$HOME/.config/klipper_backup_script/backup.cfg"
	echo "BACKUP_INTERVAL=${BACKUP_INTERVAL}" >> "$HOME/.config/klipper_backup_script/backup.cfg"
	echo "TIME_UNIT=${TIME_UNIT}" >> "$HOME/.config/klipper_backup_script/backup.cfg"
}

setup_ssh() {
	mkdir -p "$HOME/.ssh"
	if [[ -f "$HOME/.ssh/github_id_rsa" ]]
  then
  	print_msg green "SSH Key found"
		while ! check_yn $KEY_ALREADY_ADDED
  	do
  		KEY_ALREADY_ADDED=$(get_input "Did you already add this key to your GitHub account?")
      KEY_ALREADY_ADDED=${KEY_ALREADY_ADDED:-n}
  		case $KEY_ALREDAY_ADDED in
  			n|N)
  				print_msg none "Please add this key to your GitHub account:"
  				cat "$HOME/.ssh/github_id_rsa.pub"
  				print_msg purple "You can find instructions for this here:"
  			  print_msg none "https://github.com/Low-Frequency/klipper_backup_script"
  				CONTINUE=$(get_input "Press enter to continue") ;;
  			y|Y)
  				print_msg green "Continuing setup" ;;
  			*)
  				print_msg red "Unsupported answer!" ;;
  		esac
  	done
	else
  	print_msg none "Generating SSH key pair"
		if [ -z ${GITHUB_MAIL+x} ]
		then
			print_msg red "Please configure your mail address first"
		else
  		ssh-keygen -t ed25519 -C "$GITHUB_MAIL" -f "$HOME/.ssh/github_id_rsa" -q -N ""
  		echo "IdentityFile $HOME/.ssh/github_id_rsa" >> "$HOME/.ssh/config"
  		chmod 600 "$HOME/.ssh/config"
			print_msg none "Please copy the public key and add it to your GitHub account:"
  		cat "$HOME/.ssh/github_id_rsa.pub"
  		print_msg purple "You can find instructions for this here:"
  		print_msg none "https://github.com/Low-Frequency/klipper_backup_script"
  		CONTINUE=$(get_input "Press enter to continue")
		fi
  fi
}

end_script() {
  QUIT=$(get_input "Do you want to quit the installer?" | tr '[:upper:]' '[:lower:]')
  case $QUIT in
    y|yes)
      exit 0 ;;
    *)
      print_msg none "Resuming" ;;
  esac
}

install() {
	print_msg none "This is the current config:"
	get_config
	INSTALL=$(get_input "Install with the current config?")
	if check_no $INSTALL
	then
		print_msg red "Install was cancelled"
		return
	else
		print_msg green "Installing"
	fi
	chmod +x "$HOME"/scripts/klipper_backup_script/*.sh
	print_msg purple "Saving config"
	save_config
	print_msg purple "Checking if requirements are met"
	if ! command -v git &> /dev/null
  then
    print_msg red "Git is not installed"
		print_msg purple "Installing..."
    "${SCRIPTPATH}/install-git.sh"
  else
    if [[ $GIT_VERSION -lt 2280 ]]
		then
			print_msg red "Git version requirement is not met!"
			print_msg purple "Installing latest version"
			"${SCRIPTPATH}/install-git.sh"
		else
			print_msg green "Git is installed and meets version requirement"
		fi
  fi
  mkdir -p "$HOME/backup_log"
	for i in ${!GITHUB_REPO_LIST[@]}
	do
	  if [[ -d "$HOME/${GITHUB_CONFIG_FOLDER_LIST[$i]}/.git" ]]
	  then
	    print_msg red "$HOME/${GITHUB_CONFIG_FOLDER_LIST[$i]} is already a repository!"
	    print_msg red "Skipping"
	  else
			print_msg purple "Initializing $HOME/${GITHUB_CONFIG_FOLDER_LIST[$i]}"
	    git -C "$HOME/${GITHUB_CONFIG_FOLDER_LIST[$i]}" init --initial-branch=$GITHUB_BRANCH
	    git -C "$HOME/${GITHUB_CONFIG_FOLDER_LIST[$i]}" remote add origin "https://github.com/$GITHUB_USER/${GITHUB_REPO_LIST[$i]}"
	    git -C "$HOME/${GITHUB_CONFIG_FOLDER_LIST[$i]}" remote set-url origin "git@github.com:$GITHUB_USER/${GITHUB_REPO_LIST[$i]}.git"
	  fi
	done
	git config --global user.email "$GITHUB_MAIL"
	git config --global user.name "$GITHUB_USER"
	print_msg purple "Testing SSH connention"
  ssh -T git@github.com
	if [[ -f /etc/systemd/system/gitbackup.service ]]
	then
		print_msg green "Service already set up"
	else
		print_msg purple "Setting up the service"
		sudo echo "$SERVICE_FILE" >> /etc/systemd/system/gitbackup.service
	fi
  sudo chown root:root /etc/systemd/system/gitbackup.service
  sudo systemctl enable gitbackup.service
  sudo systemctl start gitbackup.service
	print_msg purple "Setting up custom commands"
	sudo ln -s "$HOME/scripts/klipper_backup_script/klipper_config_git_backup.sh" /usr/local/bin/backup
	sudo ln -s "$HOME/scripts/klipper_backup_script/restore_config.sh" /usr/local/bin/restore
	sudo ln -s "$HOME/scripts/klipper_backup_script/uninstall.sh" /usr/local/bin/uninstall_bak_util
	print_msg green "Installation complete"
}
