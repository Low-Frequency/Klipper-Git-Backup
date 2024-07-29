#!/bin/bash

backup_kgb_config() {
  ### Backup the KGB config

  log_msg "Backing up KGB config"

  ### Make sure KGB backup dir exists
  mkdir -p "${HOME}/kgb-data/backups/kgb"

  ### Copy KGB config
  cp "${HOME}/.config/kgb.cfg" "${HOME}/kgb-data/backups/kgb/kgb.cfg"

  ### Sanitize config backup to not leak mail addresses
  sed -i 's/^GITHUB_MAIL=.*$/GITHUB_MAIL=""/g' "${HOME}/kgb-data/backups/kgb/kgb.cfg"
}

backup_spoolman_data() {
  ### Backup spoolman database

  log_msg "Backing up Spoolman database"

  ### Make sure spoolman dir exists
  mkdir -p "${HOME}/kgb-data/backups/spoolman"

  ### Copy spoolman database
  cp "${SPOOLMAN_DATA}/spoolman.db" "${HOME}/kgb-data/backups/spoolman/spoolman.db"
}

backup_config_folders() {
  ### Backup all config folders

  local src

  ### Loop over all folders in config
  #!  Creates a backup of all instances
  for dir in "${CONFIG_FOLDER_LIST[@]}"; do
    log_msg "Creating local backup of ${dir}"
    ### Get the name of the printer_data directory
    dir_name="$(echo "${dir}" | sed -E 's|^.*/(.*_data)/?$|\1|')"
    ### Check if config folders match the format
    if [[ ${dir_name} == "config" ]]; then
      log_msg "Config folders must only point to printer data directory"
      log_msg "Can't backup ${dir}"
      log_msg "Please fix the config"
    else
      ### Removing potential double slashes from the source path
      #!  Won't hurt to have double slashes, just looks nicer in the log
      src="$(echo "${dir}/config" | sed 's|//|/|g')"
      ### Creating the instance folder
      if [[ -d "${HOME}/kgb-data/backups/${dir_name}" ]]; then
        log_msg "Backup directory ${HOME}/kgb-data/backups/${dir_name} already exists"
      else
        log_msg "Creating backup directory ${HOME}/kgb-data/backups/${dir_name}"
        mkdir -p "${HOME}/kgb-data/backups/${dir_name}"
      fi
      ### Copy the config
      log_msg "Backing up to local repo"
      log_msg "${src} -> ${HOME}/kgb-data/backups/${dir_name}"
      cp -r "${src}" "${HOME}/kgb-data/backups/${dir_name}"
      ### Reset the source path to avoid conflicts
      src=""
    fi
  done
}

push_backup() {
  ### Push local backup to GitHub

  ### Push backup to GitHub
  log_msg "Adding changes to push"
  git -C "${HOME}/kgb-data/backups/" add . | tee -a "${HOME}/kgb-data/log/$(date +%F).log" &>/dev/null
  log_msg "Committing to Git repository"
  git -C "${HOME}/kgb-data/backups/" commit -m "backup $(date +"%F %T")" | tee -a "${HOME}/kgb-data/log/kgb-$(date +%F).log" &>/dev/null
  log_msg "Pushing to Git repository"
  if ! git -C "${HOME}/kgb-data/backups/" push -u origin "${GITHUB_BRANCH}" | tee -a "${HOME}/kgb-data/log/kgb-$(date +%F).log" &>/dev/null; then
    return 1
  fi

  ### Return backup status
  return 0
}

backup() {
  ### Backup all configs

  ### Initialize exit code
  local error=0

  ### Remove all local backups to be able to track deleted files
  #!  Leave .git dir intact
  for dir in $(find "${HOME}/kgb-data/backups" -type d -not \( -path "${HOME}/kgb-data/backups/.git" -prune \) | grep -vE "^${HOME}/kgb-data/backups$"); do
    rm -rf "${dir}"
  done

  ### Evaluate configuration
  case ${GIT} in
    0)
      log_msg "Backups are disabled"
      ;;
    1)
      error=$(backup_config_folders)
      ;;
    *)
      log_msg "No valid backup configuration"
      log_msg "Please check the config file!"
      exit 1
      ;;
  esac

  ### Backup KGB config
  backup_kgb_config

  ### Backup spoolman database
  if [[ -n ${SPOOLMAN_DATA} ]]; then
    backup_spoolman_data
  fi

  ### Push backup to GitHub
  error=$(push_backup)

  ### Log rotation
  if ! log_rotation; then
    log_msg "This may eat up the space on your SD card!"
    log_msg "Please check the config file!"
  fi

  ### Evaluate backup status
  if push_backup; then
    log_msg "Successfully pushed backup"
    return 0
  else
    log_msg "Failed to push backup"
    return 1
  fi
}
