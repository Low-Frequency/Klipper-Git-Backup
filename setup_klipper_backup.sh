#!/bin/bash

### VARIABLES
REGEX_SPACE=" |'"
REGEX_SLASH="\/"
DRIVE_REMOTE_NAME="placeholder to make the loop go"
DRIVE_REMOTE_FOLDER="placeholder to make the loop go"
GIT_VERSION=$(git --version | cut -b 13- | sed -e 's/\.//g')

### FUNCTIONS
function check_yes_no {
  ANSWER=$1
  case $ANSWER in
    y|Y|n|N)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

function check_number {
  ANSWER=$1
  case $ANSWER in
    [0-9])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

function check_interval_unit {
  ANSWER=$1
  case $ANSWER in
    s|m|h|d)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

function instance_check {
  echo -e "\nPlease answer the following questions"
  echo -e "The options in CAPS are default answers. You can leave the answer empty to accept the default\n"

  while ! check_yes_no $KIAUH_SETUP
  do
    read -p "Did you set up your klipper instance with kiauh? [y|N] " KIAUH_SETUP
    KIAUH_SETUP=${KIAUH_SETUP:-n}

    case $KIAUH_SETUP in
      y|Y)
        LOCAL_FOLDER_APPEND="/config"
        ;;
      *)
        LOCAL_FOLDER_APPEND=
        ;;
    esac
  done

  while ! check_yes_no $KLIPPER_INSTANCES
  do 
    read -p "Do you run multiple instances of klipper on this device? [y|N] " KLIPPER_INSTANCES
    KLIPPER_INSTANCES=${KLIPPER_INSTANCES:-n}

    case $KLIPPER_INSTANCES in
      y|Y)
        while ! check_number $KLIPPER_INSTANCE_NUMBER
        do
          read -p "How many instances do you run? " KLIPPER_INSTANCE_NUMBER

          case $KLIPPER_INSTANCE_NUMBER in
            [0-9])
              ;;
            *)
              echo "Please provide a valid answer"
              ;;
          esac
        done
        ;;
      n|N)
        KLIPPER_INSTANCE_NUMBER=1
        ;;
      *)
        echo "Please provide a valid answer"
        ;;
    esac
  done
}

function setup_git_repo {
  ### Check for .ssh folder and create it when necessary
  echo "Checking for necessary folders"

  if [[ -d "$HOME/.ssh" ]]
  then
	  echo "SSH folder already exists"
  else
	  echo "Creating SSH folder"
	  mkdir "$HOME/.ssh"
  fi

  ### Getting GitHub information
  echo "Setting up $KLIPPER_INSTANCE_NUMBER repositories for backups"
  read -p "Please enter your GitHub Username: " GITHUB_USER
  REPO_COUNT=1
  while [[ $KLIPPER_INSTANCE_NUMBER -ne 0 ]]
  do
    read -p "Please enter the name of your $REPO_COUNT. GitHub repository: " GITHUB_REPO
    GITHUB_REPO_LIST+=("$GITHUB_REPO")
    read -p "Please enter the name of the $REPO_COUNT. klipper_config, or printer_data folder to be backed up (Leave empty for default klipper_config): " CONFIG_FOLDER
    CONFIG_FOLDER=${CONFIG_FOLDER:-klipper_config}
    GITHUB_CONFIG_FOLDER_LIST+=("$CONFIG_FOLDER")
    KLIPPER_INSTANCE_NUMBER=$(( $KLIPPER_INSTANCE_NUMBER - 1 ))
    REPO_COUNT=$(( $REPO_COUNT + 1 ))
    CONFIG_FOLDER=
  done
  read -p "Please enter the name of your GitHub branch (Leave empty for default main branch): " GITHUB_BRANCH
  GITHUB_BRANCH=${GITHUB_BRANCH:-main}

  ### SSH key check
  echo -e "\nChecking for GitHub SSH key"

  if [[ -f "$HOME/.ssh/github_id_rsa" ]]
  then
  	echo -e "SSH key already present\n"

  	while ! check_yes_no $KEY_ALREADY_ADDED
  	do
  		read -p "Did you already add this key to your GitHub account? [y|N] " KEY_ALREADY_ADDED
      KEY_ALREADY_ADDED=${KEY_ALREADY_ADDED:-n}

  		case $KEY_ALREDAY_ADDED in
  			n|N)
  				echo -e "Please add this key to your GitHub account:\n"
  				cat "$HOME/.ssh/github_id_rsa.pub"
  				echo -e "\nYou can find instructions for this here:"
  			  echo -e"https://github.com/Low-Frequency/klipper_backup_script\n"
  				read -p "Press enter to continue" CONTINUE
  				;;
  			y|Y)
  				echo "Continuing setup"
  				;;
  			*)
  				echo "Unsupported answer. Try again [y|N]"
  				;;
  		esac
  	done
  else
  	echo "Generating SSH key pair"
  	read -p "Please enter the e-mail of your GitHub account: " GITHUB_MAIL
  	ssh-keygen -t ed25519 -C "$GITHUB_MAIL" -f "$HOME/.ssh/github_id_rsa" -q -N ""
  	echo "IdentityFile $HOME/.ssh/github_id_rsa" >> "$HOME/.ssh/config"
  	chmod 600 "$HOME/.ssh/config"

  	echo -e "Please copy the public key and add it to your GitHub account:\n"
  	cat "$HOME/.ssh/github_id_rsa.pub"
  	echo -e "\nYou can find instructions for this here:"
  	echo -e "https://github.com/Low-Frequency/klipper_backup_script\n"
  	read -p "Press enter to continue" CONTINUE
  fi

  ### Setting up the repositories
  echo -e "\nInitializing repositories"

  for i in ${!GITHUB_REPO_LIST[@]}
  do
    git -C "$HOME/${GITHUB_CONFIG_FOLDER_LIST[$i]}$LOCAL_FOLDER_APPEND" init --initial-branch=$GITHUB_BRANCH
    git -C "$HOME/${GITHUB_CONFIG_FOLDER_LIST[$i]}$LOCAL_FOLDER_APPEND" remote add origin "https://github.com/$GITHUB_USER/${GITHUB_REPO_LIST[$i]}"
    git -C "$HOME/${GITHUB_CONFIG_FOLDER_LIST[$i]}$LOCAL_FOLDER_APPEND" remote set-url origin "git@github.com:$GITHUB_USER/${GITHUB_REPO_LIST[$i]}.git"
  done

  git config --global user.email "$GITHUB_MAIL"
  git config --global user.name "$GITHUB_USER"
}

function setup_google_drive {
  ## Installing dependencies
  echo "Installing dependencies"
  curl https://rclone.org/install.sh | sudo bash
  sudo apt install expect

  echo -e "\nSetting up a remote location for your backup"
  while [[ $DRIVE_REMOTE_NAME =~ $REGEX_SPACE || $DRIVE_REMOTE_NAME =~ $REGEX_SLASH ]]
  do
  	read -p "Please name your remote storage (no spaces, or / allowed. Default: googledrive): " DRIVE_REMOTE_NAME
    DRIVE_REMOTE_NAME=${DRIVE_REMOTE_NAME:-googledrive}
  done

  ## Specifying backup folder
  echo -e "\nSetting up $KLIPPER_INSTANCE_NUMBER folders in the remote location for your backups"
  FOLDER_COUNT=1
  while [[ $KLIPPER_INSTANCE_NUMBER -ne 0 ]]
  do
    while [[ $DRIVE_REMOTE_FOLDER =~ $REGEX_SPACE || $DRIVE_REMOTE_FOLDER =~ $REGEX_SLASH ]]
    do
    	read -p "Please specify the $FOLDER_COUNT. folder to backup into (no spaces, or / allowed): " DRIVE_REMOTE_FOLDER
    done
    read -p "Please enter the name of the $FOLDER_COUNT. klipper_config, or printer_data folder to be backed up (Leave empty for default klipper_config): " CONFIG_FOLDER
    CONFIG_FOLDER=${CONFIG_FOLDER:-klipper_config}
    DRIVE_REMOTE_FOLDER_LIST+=($DRIVE_REMOTE_FOLDER)
    DRIVE_CONFIG_FOLDER_LIST+=("$CONFIG_FOLDER")
    CONFIG_FOLDER=
    DRIVE_REMOTE_FOLDER="/"
    KLIPPER_INSTANCE_NUMBER=$(( $KLIPPER_INSTANCE_NUMBER - 1 ))
    FOLDER_COUNT=$(( $FOLDER_COUNT + 1 ))
  done

  ## Configuring rclone
  "$HOME/scripts/klipper_backup_script/drive.exp" "$DRIVE_REMOTE_NAME"
}

function generate_config {
  echo "Generating config file"

  if [[ $DRIVE_REMOTE_NAME == "placeholder to make the loop go" ]]
  then
    DRIVE_REMOTE_NAME=
  fi

  if [[ $DRIVE_REMOTE_FOLDER == "placeholder to make the loop go" ]]
  then
    DRIVE_REMOTE_NAME=
  fi

  if [[ $GOOGLE_DRIVE_ENABLED == "y" ]]
  then
    sed -i "s/^REMOTE=.*/REMOTE=$DRIVE_REMOTE_NAME/g" "$HOME/.config/klipper_backup_script/backup.cfg"
    if ! grep -q DRIVE_REMOTE_FOLDER_LIST "$HOME/.config/klipper_backup_script/backup.cfg"
    then
      echo "DRIVE_REMOTE_FOLDER_LIST=(${DRIVE_REMOTE_FOLDER_LIST[@]})" >> "$HOME/.config/klipper_backup_script/backup.cfg"
    else
      echo "DONT RUN THIS SCRIPT TWICE! IT MAY BREAK THE BACKUP UTILITY!"
      exit 1
    fi
    sed -i 's/^CLOUD=.*/CLOUD=1/g' "$HOME/.config/klipper_backup_script/backup.cfg"
  else
    sed -i 's/^CLOUD=.*/CLOUD=0/g' "$HOME/.config/klipper_backup_script/backup.cfg"
  fi

  if [[ $GITHUB_ENABLED == "y" ]]
  then 
    sed -i "s/^USER=.*/USER=$GITHUB_USER/g" "$HOME/.config/klipper_backup_script/backup.cfg"
    sed -i "s/^BRANCH=.*/BRANCH=$GITHUB_BRANCH/g" "$HOME/.config/klipper_backup_script/backup.cfg"
    if ! grep -q GITHUB_REPO_LIST "$HOME/.config/klipper_backup_script/backup.cfg"
    then
      echo "GITHUB_REPO_LIST=(${GITHUB_REPO_LIST[@]})" >> "$HOME/.config/klipper_backup_script/backup.cfg"
    else
      echo "DONT RUN THIS SCRIPT TWICE! IT MAY BREAK THE BACKUP UTILITY!"
      exit 1
    fi
    if ! grep -q GITHUB_CONFIG_FOLDER_LIST "$HOME/.config/klipper_backup_script/backup.cfg"
    then
      echo "GITHUB_CONFIG_FOLDER_LIST=(${GITHUB_CONFIG_FOLDER_LIST[@]})" >> "$HOME/.config/klipper_backup_script/backup.cfg"
    else
      echo "DONT RUN THIS SCRIPT TWICE! IT MAY BREAK THE BACKUP UTILITY!"
      exit 1
    fi
    if ! grep -q LOCAL_FOLDER_APPEND "$HOME/.config/klipper_backup_script/backup.cfg"
    then
      echo "LOCAL_FOLDER_APPEND=$LOCAL_FOLDER_APPEND" >> "$HOME/.config/klipper_backup_script/backup.cfg"
    else
      echo "DONT RUN THIS SCRIPT TWICE! IT MAY BREAK THE BACKUP UTILITY!"
      exit 1
    fi
    sed -i 's/^GIT=.*/GIT=1/g' "$HOME/.config/klipper_backup_script/backup.cfg"
  else
    sed -i 's/^GIT=.*/GIT=0/g' "$HOME/.config/klipper_backup_script/backup.cfg"
  fi

  if [[ $LOG_ROTATION_ENABLED == "y" ]]
  then
    sed -i 's/^ROTATION=.*/ROTATION=1/g' "$HOME/.config/klipper_backup_script/backup.cfg"
    sed -i "s/^RETENTION=.*/RETENTION=$LOG_RETENTION/g" "$HOME/.config/klipper_backup_script/backup.cfg"
  else
    sed -i 's/^ROTATION=.*/ROTATION=0/g' "$HOME/.config/klipper_backup_script/backup.cfg"
  fi

  if [[ $BACKUP_INTERVALS_ENABLED == "y" ]]
  then
    sed -i 's/^INTERVAL=.*/INTERVAL=1/g' "$HOME/.config/klipper_backup_script/backup.cfg"
    sed -i "s/^TIME=.*/TIME=$BACKUP_INTERVAL/g" "$HOME/.config/klipper_backup_script/backup.cfg"
    sed -i "s/^UNIT=.*/UNIT=$BACKUP_INTERVAL_UNIT/g" "$HOME/.config/klipper_backup_script/backup.cfg"
  else
    sed -i 's/^INTERVAL=.*/INTERVAL=0/g' "$HOME/.config/klipper_backup_script/backup.cfg"
  fi

  if ! grep -q DRIVE_CONFIG_FOLDER_LIST "$HOME/.config/klipper_backup_script/backup.cfg"
  then
    echo "DRIVE_CONFIG_FOLDER_LIST=(${DRIVE_CONFIG_FOLDER_LIST[@]})" >> "$HOME/.config/klipper_backup_script/backup.cfg"
  else
    echo "DONT RUN THIS SCRIPT TWICE! IT MAY BREAK THE BACKUP UTILITY!"
    exit 1
  fi

  echo "Config file successfully generated"
}

function check_requirements {
  echo "Checking if git is installed"

  if ! command -v git &> /dev/null
  then
    echo "Git is not installed. Installing..."
    sudo apt-get install git -y
  else
    echo "Git already installed"
  fi

  echo "Checking for directories"

  if [[ -d "$HOME/scripts" ]]
  then
    echo "Scripts folder already exists"
  else
    echo "Crating scripts folder"
    mkdir "$HOME/scripts"
  fi

  if [[ -d "$HOME/backup_log" ]]
  then
    echo "Log folder already exists"
  else
    echo "Creating log folder"
    mkdir "$HOME/backup_log"
  fi

  echo "Downloading backup script"
  if [[ ! -d "$HOME/scripts/klipper_backup_script" ]]
  then
    git -C "$HOME/scripts" clone https://github.com/Low-Frequency/klipper_backup_script
  else
    git pull origin main
  fi

  chmod +x "$HOME"/scripts/klipper_backup_script/*.sh && chmod +x "$HOME"/scripts/klipper_backup_script/*.exp

  if [[ ! -d "$HOME/.config/klipper_backup_script" ]]
  then
    mkdir -p "$HOME/.config/klipper_backup_script"
  fi

  mv "$HOME/scripts/klipper_backup_script/backup.cfg" "$HOME/.config/klipper_backup_script/"
}

function setup_service {
  sed -i "s/^User=.*/User=$USER/g" "$HOME/scripts/klipper_backup_script/gitbackup.service"
  sed -i "s|ExecStart=.*|ExecStart=$HOME\/scripts\/klipper_backup_script\/klipper_config_git_backup.sh|g" "$HOME/scripts/klipper_backup_script/gitbackup.service"
  echo ""
  echo "Setting up the service"
  sudo mv "$HOME/scripts/klipper_backup_script/gitbackup.service" /etc/systemd/system/gitbackup.service
  sudo chown root:root /etc/systemd/system/gitbackup.service
  sudo systemctl enable gitbackup.service
  sudo systemctl start gitbackup.service
}

function enable_backups {
  while ! check_yes_no $GITHUB_ENABLED
  do
  	read -p "Do you want to enable GitHub as a backup location? [Y|n] " GITHUB_ENABLED
    GITHUB_ENABLED=${GITHUB_ENABLED:-y}
  	case $GITHUB_ENABLED in
  		n|N)
  			echo "GitHub backup disabled"
  			;;
  		y|Y)
  			if [[ $GIT_VERSION -lt 2280 ]]
  			then
        echo "You have to update git"
        echo "To get the newest version, you have to install git from the source"
        read -p "Do you want to update git now? [Y|n] " INSTALL_GIT
        while ! check_yes_no $INSTALL_GIT
        do
          case $INSTALL_GIT in
            n|N)
              echo "Please follow the guide linked in the install section in the repo and try again"
              exit 1
              ;;
            y|Y)
              "$HOME/scripts/klipper_backup_script/install-git.sh"
              ;;
            *)
              echo "Please provide a valid answer\n"
              ;;
          esac
  			fi
  			echo "GitHub backup enabled"
  			setup_git_repo
        echo "Testing SSH connention"
  	    ssh -T git@github.com
  			;;
  		*)
  			echo -e "Please provide a valid answer\n"
  			;;
  	esac
  done

  # Drive Support disabled due to changes in rclone
  GOOGLE_DRIVE_ENABLED=n

  while ! check_yes_no $GOOGLE_DRIVE_ENABLED
  do
    read -p "Do you want to enable Google Drive backup? [y|N] " GOOGLE_DRIVE_ENABLED
    GOOGLE_DRIVE_ENABLED=${GOOGLE_DRIVE_ENABLED:-n}
    case $GOOGLE_DRIVE_ENABLED in
      n|N)
        echo "Google Drive backup disabled"
        ;;
      y|Y)
        echo "Google Drive backup enabled"
  		  echo "Configuring..."
  		  setup_google_drive
        ;;
      *)
        echo -e "Please provide a valid answer\n"
        ;;
    esac
  done
}

function enable_log_rotation {
  echo "Do you want to enable log rotation?"
  echo "This can save space on your SD card"
  echo "This is recommended, if you choose to backup to Google Drive or configured scheduled backups"

  while ! check_yes_no $LOG_ROTATION_ENABLED
  do
    read -p 'Enable log rotation? [Y|n] ' LOG_ROTATION_ENABLED
    LOG_ROTATION_ENABLED=${LOG_ROTATION_ENABLED:-y}

    case $LOG_ROTATION_ENABLED in
      n|N)
        echo "Log rotation disabled"
        ;;
      y|Y)
        read -p "How long should the logs be kept (in months). Default is 3 months: " LOG_RETENTION
        LOG_RETENTION=${LOG_RETENTION:-3}
        ;;
      *)
        echo "Please provide a valid answer"
        ;;
    esac
  done
}

function enable_schedule {
  while ! check_yes_no $BACKUP_INTERVALS_ENABLED
  do
    echo "Right now backups are only done while starting the system"
    read -p "Do you want to do backups during operation on a set timeschedule? [y|N] " BACKUP_INTERVALS_ENABLED
    BACKUP_INTERVALS_ENABLED=${BACKUP_INTERVALS_ENABLED:-n}
    case $BACKUP_INTERVALS_ENABLED in
      y|Y)
        echo "Enabling scheduled backups"
        while ! check_interval_unit $BACKUP_INTERVAL_UNIT
        do
          echo "Please specify an interval and a time unit"
          echo "Available are:"
          echo "s: seconds"
          echo "m: minutes"
          echo "h: hours"
          echo "d: days"
          echo "Note that too frequent backups can impact system performance!"
          read -p "Unit: " BACKUP_INTERVAL_UNIT
        done
        while ! check_number $BACKUP_INTERVAL
        do
          read -p "Intervals: " BACKUP_INTERVAL
        done
        ;;
      n|N)
        echo "Disabling scheduled backups"
        ;;
      *)
        echo "Please provide a valid answer"
        ;;
    esac
  done
}

### SETUP SCRIPT
check_requirements
instance_check
enable_backups
enable_schedule
enable_log_rotation
generate_config
setup_service

sudo ln -s "$HOME/scripts/klipper_backup_script/klipper_config_git_backup.sh" /usr/local/bin/backup
sudo ln -s "$HOME/scripts/klipper_backup_script/restore_config.sh" /usr/local/bin/restore
sudo ln -s "$HOME/scripts/klipper_backup_script/uninstall.sh" /usr/local/bin/uninstall_bak_util

rm "$HOME/setup_klipper_backup.sh"