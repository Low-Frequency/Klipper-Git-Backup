#!/bin/bash

write_line_to_config() {
  LINE="$1"
  echo "$LINE" >> "$HOME/.config/kgb.cfg"
}

save_config() {
  mkdir -p "$HOME/.config"
  if [[ -f "$HOME/.config/kgb.cfg" ]]
  then
    rm "$HOME/.config/kgb.cfg"
  fi
  if [[ -z ${NAMESPACE+x} ]]
  then
    NAMESPACE="$GITHUB_USER"
  fi
  write_line_to_config "GIT=${GIT}"
  write_line_to_config "GIT_BASE_URL=${GIT_BASE_URL}"
  write_line_to_config "NAMESPACE=${NAMESPACE}"
  write_line_to_config "GITHUB_USER=${GITHUB_USER}"
  write_line_to_config "GITHUB_MAIL=${GITHUB_MAIL}"
  write_line_to_config "GITHUB_BRANCH=${GITHUB_BRANCH}"
  write_line_to_config "REPO_LIST=($(echo ${REPO_LIST[@]}))"
  write_line_to_config "CONFIG_FOLDER_LIST=($(echo ${CONFIG_FOLDER_LIST[@]}))"
  write_line_to_config "LOG_ROTATION=${LOG_ROTATION}"
  write_line_to_config "LOG_RETENTION=${LOG_RETENTION}"
  write_line_to_config "SCHEDULED_BACKUPS=${SCHEDULED_BACKUPS}"
  write_line_to_config "BACKUP_INTERVAL=${BACKUP_INTERVAL}"
  write_line_to_config "TIME_UNIT=${TIME_UNIT}"
  UNSAVED_CHANGES=0
}

show_config() {
  info_msg "### Current configuration ###"
  if [[ $GIT -eq 1 ]]
  then
    success_msg "Backups are enabled"
    info_msg "GITHUB_USER: ${GITHUB_USER}"
    info_msg "GITHUB_MAIL: ${GITHUB_MAIL}"
    info_msg "GITHUB_BRANCH: ${GITHUB_BRANCH}"
    info_msg "GIT_BASE_URL: ${GIT_BASE_URL}"
    info_msg "NAMESPACE: ${NAMESPACE}"
    for (( i=0; i<${#REPO_LIST[@]}; i++ ))
    do
      info_msg "Repository #$(( i + 1 )): ${REPO_LIST[$i]}"
      info_msg "Config folder #$(( i + 1 )): ${CONFIG_FOLDER_LIST[$i]}"
    done
  else
    error_msg "Backups are disabled"
  fi
  if [[ $LOG_ROTATION -eq 1 ]]
  then
    success_msg "Log rotation is enabled"
    info_msg "LOG_RETENTION=${LOG_RETENTION}"
  else
    error_msg "Log rotation is disabled"
  fi
  if [[ $SCHEDULED_BACKUPS -eq 1 ]]
  then
    success_msg "Scheduled Backups are enabled"
    info_msg "TIME_UNIT=${TIME_UNIT}"
    info_msg "BACKUP_INTERVAL=${BACKUP_INTERVAL}"
  else
    error_msg "Scheduled backups are disabled"
  fi
  echo ""
  read -p "$(echo -e "${CYAN}Press enter to continue ${NC}")" CONTINUE
}

setup_ssh() {
  info_msg "Setting up SSH"
  mkdir -p "$HOME/.ssh"
  if [[ -f "$HOME/.ssh/github_id_rsa" ]]
  then
    success_msg "SSH Key found"
    while true
    do
      read -p "$(echo -e "${CYAN}Did you already add this key to your GitHub account? ${NC}")" KEY_ALREADY_ADDED
      KEY_ALREADY_ADDED=${KEY_ALREADY_ADDED:-n}
      case $KEY_ALREADY_ADDED in
        n|N)
          info_msg "Please add this public key to your GitHub account:"
          cat "$HOME/.ssh/github_id_rsa.pub"
          info_msg "You can find instructions for this here:"
          info_msg "https://github.com/Low-Frequency/klipper_backup_script"
          read -p "$(echo -e "${CYAN}Press enter to continue ${NC}")" CONTINUE
          break
          ;;
        y|Y)
          success_msg "Continuing setup"
          break
          ;;
        *)
          deny_action
          ;;
      esac
    done
  else
    info_msg "Generating new SSH key pair"
    if [[ -z ${GITHUB_MAIL+x} ]]
    then
      error_msg "Please configure your mail address first"
      return 1
    else
      ssh-keygen -t ed25519 -C "$GITHUB_MAIL" -f "$HOME/.ssh/github_id_rsa" -q -N ""
      echo "IdentityFile $HOME/.ssh/github_id_rsa" >> "$HOME/.ssh/config"
      chmod 600 "$HOME/.ssh/config"
      info_msg "Please copy the public key and add it to your GitHub account:"
      cat "$HOME/.ssh/github_id_rsa.pub"
      info_msg "You can find instructions for this here:"
      info_msg "https://github.com/Low-Frequency/klipper_backup_script"
      read -p "$(echo -e "${CYAN}Press enter to continue ${NC}")" CONTINUE
    fi
  fi
  return 0
}

install() {
  success_msg "Installing"
  chmod +x "${SCRIPTPATH}/"*.sh
  info_msg "Checking if requirements are met"
  if ! command -v git &> /dev/null
  then
    error_msg "Git is not installed"
    info_msg "Installing..."
    "${SCRIPTPATH}/install-git.sh"
  else
    GIT_VERSION=$(git --version | cut -b 13- | sed -e 's/\.//g')
    if [[ $GIT_VERSION -lt 2280 ]]
    then
      error_msg "Git version requirement is not met!"
      info_msg "Installing latest version"
      if install_git
      then
        success_msg "Successfully installed git"
      else
        error_msg "Error while installing git"
        error_msg "Cancelling install"
        return 1
      fi
    else
      success_msg "Git is installed and meets version requirement"
    fi
  fi
  mkdir -p "$HOME/kgb-log"
  git config --global user.email "$GITHUB_MAIL"
  git config --global user.name "$GITHUB_USER"
  for i in ${!REPO_LIST[@]}
  do
    if [[ -d "${CONFIG_FOLDER_LIST[$i]}/.git" ]]
    then
      warning_msg "${CONFIG_FOLDER_LIST[$i]} is already a repository!"
      warning_msg "Skipping"
    else
      info_msg "Initializing ${CONFIG_FOLDER_LIST[$i]}"
      git -C "${CONFIG_FOLDER_LIST[$i]}" init --initial-branch=$GITHUB_BRANCH
      git -C "${CONFIG_FOLDER_LIST[$i]}" remote add origin "https://${GIT_BASE_URL}/${NAMESPACE}/${REPO_LIST[$i]}.git"
      git -C "${CONFIG_FOLDER_LIST[$i]}" remote set-url origin "git@${GIT_BASE_URL}:${NAMESPACE}/${REPO_LIST[$i]}.git"
      git -C "${CONFIG_FOLDER_LIST[$i]}" push --set-upstream origin "$GITHUB_BRANCH"
    fi
  done
  info_msg "Testing SSH connention"
  ssh -T git@github.com
  if [[ -f /etc/systemd/system/kgb.service ]]
  then
    success_msg "Service was already set up"
  else
    info_msg "Setting up the service"
    sudo echo "$SERVICE_FILE" >> "${SCRIPTPATH}/kgb.service"
    mv "${SCRIPTPATH}/kgb.service" /etc/systemd/system/kgb.service
    sudo chown root:root /etc/systemd/system/kgb.service
    sudo systemctl enable kgb.service
    sudo systemctl start kgb.service
  fi
  success_msg "Installation complete"
  read -p "$(echo -e "${CYAN}Press enter to continue ${NC}")" CONTINUE
}
