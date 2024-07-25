#!/bin/bash

backup_config_folders() {
  ### Backup all config folders

  ### Initialize the exit code
  local error=0
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

  ### Push backup to GitHub
  log_msg "Adding changes to push"
  git -C "${HOME}/kgb-data/backups/" add . | tee -a "${HOME}/kgb-data/log/$(date +%F).log"
  log_msg "Committing to Git repository"
  git -C "${HOME}/kgb-data/backups/" commit -m "backup $(date +"%F %T")" | tee -a "${HOME}/kgb-data/log/kgb-$(date +%F).log"
  log_msg "Pushing to Git repository"
  if git -C "${HOME}/kgb-data/backups/" push -u origin "${GITHUB_BRANCH}" | tee -a "${HOME}/kgb-data/log/kgb-$(date +%F).log"; then
    log_msg "Successfully pushed backup"
  else
    log_msg "Failed to push backup"
    error=1
  fi

  ### Return backup status
  echo "${error}"
}

backup() {
  ### Backup all configs

  ### Initialize exit code
  local error=0
  local log_err=0

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

  ### Trigger log rotation
  log_err=$(log_rotation)

  ### Evaluate log rotation status
  if [[ ${log_err} -ne 0 ]]; then
    log_msg "No valid log rotation configuration!"
    log_msg "This may eat up the space on your SD card!"
    log_msg "Please check the config file!"
  fi

  ### Evaluate backup status
  if [[ ${error} -ne 0 ]]; then
    return 1
  else
    return 0
  fi
}
