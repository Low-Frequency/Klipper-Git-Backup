#!/bin/bash

detect_existing_configs() {
  ### Detects existing config files in the repo and triggers a backup or restore

  local repo_files
  local input
  local error

  ### Clonig repo
  info_msg "Cloning repo"
  if [[ -d ${HOME}/kgb-data/backups/.git ]]; then
    git -C "${HOME}/kgb-data/backups" pull &>/dev/null
  else
    git clone "git@${GIT_SERVER}:${GIT_ORG}/${GIT_REPO}.git" "${HOME}/kgb-data/backups" &>/dev/null
  fi

  ### Find all files and direcories in the repo and count them
  #!  The command excludes the .git folder, so no files or dirs in the repo folder will return 1
  repo_files="$(find "${HOME}/kgb-data/backups" -not \( -path "${HOME}/kgb-data/backups/.git" -prune \) | wc -l)"

  ### Check if number of found directories and files is 1
  #!  If number of files is greater than 1, there is at least one file or directory in the repo
  if [[ ${repo_files} -eq 1 ]]; then
    ### Initial Backup
    if backup; then
      return 0
    else
      return 1
    fi
  ### Very weird behavior
  #!  This should never happen, but print instructions just in case
  elif [[ ${repo_files} -eq 0 ]]; then
    error_msg "This should not have happened"
    error_msg "Apparently your repo folder doesn't exist"
    error_msg "I don't know how this can happen"
    error_msg "Please open an issue and paste the following output in it (including the backticks):"
    echo -e "\n\`\`\`"
    ls -lah "${HOME}/kgb-data"
    echo -e "\`\`\`\n"
    read -r -p "$(echo -e "${CYAN}Press enter to continue ${NC}")" input
    input=""
    return 1
  ### Number of files is greater than 1, so there are files in the repo
  #!  Start auto restore
  else
    auto_restore
    return 0
  fi
}

check_restore_destination() {
  ### Finds the restore destination for a backup folder

  local dir_name=$1
  local restore_dst

  ### Capture spoolman backup
  if [[ ${dir_name} =~ [Ss]poolman ]]; then
    ### Make sure spoolman restore destination exists
    if [[ -d ${SPOOLMAN_DATA} ]]; then
      restore_dst="${SPOOLMAN_DATA}"
    fi
  ### Capture KGB backup
  elif [[ ${dir_name} =~ kgb ]]; then
    restore_dst="${HOME}/.config"
  else
    ### Check if same name exists in ${HOME}
    for dst in "${HOME}"/*/; do
      if echo "${dst}" | grep -q "${dir_name}"; then
        restore_dst="${dst}"
      fi
    done
  fi

  ### Return restore destination
  echo "${restore_dst}"
}

restore_backup() {
  ### Restores a backup

  local dir=$1
  local restore_dst=$2

  if [[ -n ${restore_dst} ]]; then
    ### Capture spoolman backup
    if [[ ${restore_dst} =~ [Ss]poolman ]]; then
      ### Copy config to existing printer_data directory
      success_msg "Found restorable spoolman instance ${restore_dst}"
      cp -r "${dir}/spoolman.db" "${restore_dst}/spoolman.db"
    elif [[ ${restore_dst} == "${HOME}/.config" ]]; then
      warning_msg "Not restoring KGB backup"
      warning_msg "Currently only manual restore supported to not break the config during install"
    else
      ### Copy config to existing printer_data directory
      success_msg "Found restorable klipper instance ${restore_dst}"
      cp -r "${dir}/config/" "${restore_dst}"
    fi
  else
    warning_msg "Could not find restore destination for ${dir}"
  fi
}

auto_restore() {
  ### Automatically restores the found config files

  local input
  local restore_dst

  info_msg "Existing configs in remote repository detected"
  warning_msg "This will restore ALL configs!"
  warning_msg "To prevent data loss only restore if you've lost all of your configuration!"
  ### Prompt for restore
  while true; do
    read -r -p "$(echo -e "${PURPLE}Do you want to restore the configs now? ${NC}")" -i "y" -e input
    ### Evaluate user input
    case ${input} in
      y | Y)
        ### Start restore process
        info_msg "Starting automatic restore process for all instances"
        ### Loop over all existing backups
        for dir in "${HOME}"/kgb-data/backups/*/; do
          ### Get name of backup directory
          dir_name="$(echo "${dir}" | sed -E 's|^.*/(.*_data)/?$|\1|')"
          ### Get path to restore destination
          restore_dst="$(check_restore_destination "${dir_name}")"
          ### Restore the folder
          restore_backup "${dir}" "${restore_dst}"
          restore_dst=""
        done
        success_msg "Automatic restore finished"
        break
        ;;
      n | N)
        ### Skip restoring
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done
}

setup_git() {
  ### Global git config and connection test

  ### Configure git
  git config --global user.email "${GITHUB_MAIL}"
  git config --global user.name "${GITHUB_USER}"
  git config --global init.defaultBranch "${GITHUB_BRANCH}"
  ### Add sane limits in case server is slow or printer_data has big gcode files
  git config --global pack.windowMemory "100m"
  git config --global pack.packSizeLimit "100m"
  git config --global pack.threads "2"

  ### Testing SSH connection
  info_msg "Testing SSH connention"
  ssh -T git@"${GIT_SERVER}"
}

install() {
  ### Install the script

  local input
  local dir_name
  local git_version
  local version_number
  local restore_dst
  local required_git_version=(2 28 0)
  local git_install=0

  ## Make all scripts executable
  chmod +x "${SCRIPTPATH}/"*.sh

  ### Make sure all necessary folders exists
  mkdir -p "${HOME}/kgb-data"/{log,backups}

  ### Checking required packages
  info_msg "Checking if requirements are met"
  if ! command -v git &>/dev/null; then
    ### Requirement not met
    #!  Install dependencies
    error_msg "Git is not installed"
    info_msg "Installing..."
    install_git
  else
    ### Get current git version
    git_version=$(git --version | cut -d' ' -f3 | sed -e 's/\.//g')
    ### Check version requirement
    for i in {1..3}; do
      ### Separate version numbers to only compare major to major versions
      version_number="$(echo "${git_version}" | cut -d'.' "-f${i}")"
      if [[ ${version_number} -lt ${required_git_version[${i}]} ]]; then
        ### Verison less than requirement
        #!  Has to be reinstalled
        git_install=1
      fi
    done
    ### Install git
    if [[ ${git_install} -ne 0 ]]; then
      error_msg "Git version requirement is not met!"
      info_msg "Installing latest version"
      if install_git; then
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

  ### Configure git
  setup_git

  ### Clone the repo and perform a backup or restore
  if ! detect_existing_configs; then
    return 1
  fi

  ### Check if service has already been installed
  if [[ -f /etc/systemd/system/kgb.service ]]; then
    success_msg "Service was already set up"
  else
    ### Setup the service file
    info_msg "Setting up the service"
    echo "${SERVICE_FILE}" >>"${SCRIPTPATH}/kgb.service"
    sudo mv "${SCRIPTPATH}/kgb.service" /etc/systemd/system/kgb.service
    sudo chown root:root /etc/systemd/system/kgb.service
    sudo chmod 644 /etc/systemd/system/kgb.service
    ### Starting and enabling isn't necessary, since the timer does that
    # sudo systemctl enable kgb.service
    # sudo systemctl start kgb.service
  fi

  ### Check if the timer has already been set up
  if [[ -f /etc/systemd/system/kgb.timer ]]; then
    info_msg "Schedule was already set up"
    info_msg "Disabling the schedule temporarily"
    ### Stop and disable the timer to update it
    sudo systemctl stop kgb.timer
    sudo systemctl disable kgb.timer
    info_msg "Updating the schedule"
  else
    info_msg "Setting up the schedule"
  fi

  ### Initialize the backup schedule
  #!  This sets the timer string according to the config
  init_schedule

  ### Create local timer file
  echo "${SERVICE_TIMER}" >>"${SCRIPTPATH}/kgb.timer"
  sleep 1

  ### Replace placeholders with config variables
  sed -i "s|replace_interval|${INTERVAL}|g" "${SCRIPTPATH}/kgb.timer"
  sed -i "s|replace_persist|${PERSISTENT}|g" "${SCRIPTPATH}/kgb.timer"

  ### Move the timer file to the correct location
  #!  Also make sure ownership and permissions are correct
  sudo mv "${SCRIPTPATH}/kgb.timer" /etc/systemd/system/kgb.timer
  sudo chown root:root /etc/systemd/system/kgb.timer
  sudo chmod 644 /etc/systemd/system/kgb.timer

  ### Enable and start the schedule
  info_msg "Enabling the schedule"
  sudo systemctl daemon-reload
  sudo systemctl enable kgb.timer
  sudo systemctl start kgb.timer

  success_msg "Installation complete"
  read -r -p "$(echo -e "${CYAN}Press enter to continue ${NC}")" CONTINUE
}
