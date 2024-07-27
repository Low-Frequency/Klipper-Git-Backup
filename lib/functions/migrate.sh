#!/bin/bash

migrate_config() {
  ### Migrate to v2 config
  #!  Also installs all dependencies

  local input
  local new_dir
  local tmp_array

  ### Check if requirements are met
  if [[ ! -f ${HOME}/.secrets/gh-token ]]; then
    error_msg "Please create a GitHub access token first"
    error_msg "Instructions can be found here:"
    error_msg "https://github.com/Low-Frequency/Klipper-Git-Backup"
    return 1
  fi

  ### Check if already on v2
  if [[ ${#REPO_LIST[@]} -ne 0 ]]; then
    ### Make backup of current config
    cp "${HOME}/.config/kgb.cfg" "${HOME}/.config/kgb.cfg.v1"

    ### Remove old structure
    rm -rf "${HOME}/kgb-log"

    ### Create new folder structure
    info_msg "Creating new folder structure"
    mkdir -p "${HOME}/kgb-data"/{backups,log}

    ### Remove .git folder to avoid repos in repos
    info_msg "Removing repo config from printer data folders"
    for dir in "${CONFIG_FOLDER_LIST[@]}"; do
      rm -rf "${dir}/config/.git"
      rm -rf "${dir}/.git"
    done

    ### Ask user if repo name is okay
    info_msg "The next step will create a new repo for you"
    info_msg "The repo name is ${GIT_REPO:-klipper-backups-by-kgb}"
    ### Loop until user input is valid
    while true; do
      ### Prompt user for input
      read -r -p "$(echo -e "${PURPLE}Is this okay? ${NC}")" -i "y" -e input
      case ${input} in
        y | Y)
          break
          ;;
        n | N)
          ### Configure repo name
          config_repo
          break
          ;;
        *)
          ### Invalid input
          deny_action
          ;;
      esac
    done && input=""

    ### Fix config folder list
    for dir in "${CONFIG_FOLDER_LIST[@]}"; do
      ### Only leave path to instance folder intact
      tmp_array+=("${dir//config/}")
    done

    ### Reassign array
    CONFIG_FOLDER_LIST=("${tmp_array[@]}")

    ### Save config
    save_config

    ### Install dependencies
    if setup_ssh; then
      if detect_existing_configs; then
        success_msg "Successfully migrated config"
        ### Unset the variable since it's only used to check the config version
        unset REPO_LIST
      else
        error_msg "Migration failed!"
      fi
    else
      error_msg "Migration failed"
      error_msg "Try reinstalling the script"
    fi
  else
    success_msg "Already on v2 config"
    success_msg "Nothing to do"
  fi
}
