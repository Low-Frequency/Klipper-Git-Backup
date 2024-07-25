#!/bin/bash

quit_installer() {
  ### Exits the installer
  #!  Has some safety built in to make sure the user doesn't accidentally discards config changes

  local input

  ### Check if there are unsaved config changes
  if [[ ${UNSAVED_CHANGES} -ne 0 ]]; then
    ### Loop until user input is valid
    while true; do
      warning_msg "You have config changes pending!"
      ### Prompt user for input
      read -r -p "$(echo -e "${CYAN}Save changes now? ${NC}")" -i "y" -e input
      ### Evaluate user input to choose an action
      case ${input} in
        y | Y)
          ### Save pending changes to config
          save_config

          ### Check the installation status
          #!  Exit the loop if it is installed
          #!  Skip to the next iteration if it isn't installed
          if check_install; then
            break
          else
            return 0
          fi
          ;;
        n | N)
          warning_msg "Your changes will be lost!"
          input=""
          ### Loop until user input is valid
          while true; do
            ### Prompt user for input
            read -r -p "$(echo -e "${CYAN}Continue? ${NC}")" -i "n" -e input
            case ${input} in
              y | Y)
                warning_msg "Discarding changes"

                ### Check the installation status
                #!  Exit the loop if it is installed
                #!  Skip to the next iteration if it isn't installed
                if check_install; then
                  break
                else
                  return 0
                fi
                ;;
              n | N)
                success_msg "Resuming"
                return 0
                ;;
              *)
                ### Invalid input
                deny_action
                ;;
            esac
          done
          break
          ;;
        *)
          ### Invalid input
          deny_action
          ;;
      esac
    done && input=""
  fi

  ### Exit the installer
  success_msg "Exiting"
  exit 0
}

check_install() {
  ### Checks if the service has been installed

  local input

  ### Check if the service file exists
  #!  If not, warn the user that the installation process hasn't been completed
  if [[ ! -f /etc/systemd/system/kgb.service ]]; then
    ### Loop until user input is valid
    while true; do
      warning_msg "You haven't installed the script yet!"
      warning_msg "This will lead to errors if you want to use the script"

      ### Prompt the user for input
      read -r -p "$(echo -e "${CYAN}Continue anyway? ${NC}")" -i "n" -e input
      ### Evaluate user input to determine the return code
      case ${input} in
        y | Y)
          ### Skip installation
          return 0
          ;;
        n | N)
          ### Abort action to be able to install
          return 1
          ;;
        *)
          ### Invalid input
          deny_action
          ;;
      esac
    done && input=""
  fi
}

detect_printer_data() {
  ### Detects all directories in ${HOME} thet end in ´_data´

  local printer_data
  local re='^.*_data/$'

  ### Loop over all directories in ${HOME}
  for dir in "${HOME}"/*/; do
    ### If the directory matches, add it to a list
    if [[ ${dir} =~ ${re} ]]; then
      printer_data+=("${dir}")
    fi
  done

  ### Return all found directories
  echo "${printer_data[*]}"
}

config_folders() {
  ### Configure folders to be backed up

  local input
  local data
  local auto_detected_dirs

  ### Auto detect printer_data folders
  data=$(detect_printer_data)

  ### Make the detected printer data folders an array
  mapfile -t auto_detected_dirs < <(echo "${data}" | tr ' ' "\n")

  ### List auto detected folders
  success_msg "Detected the following config directories:"
  for i in "${!auto_detected_dirs[@]}"; do
    echo -e "$((i + 1))) ${auto_detected_dirs[${i}]}"
  done

  ### Loop until user input is valid
  echo -e "${PURPLE}Which directories should be included in the backup?${NC}"
  echo -e "${PURPLE}Choose only one per prompt${NC}"
  echo -e "${PURPLE}'y' for all detected folders${NC}"
  while true; do
    ### Prompt user for input
    input=""
    read -r -p "$(echo -e "${PURPLE}Add direcory number (x to stop adding): ${NC}")" input
    ### Validate user input
    case ${input} in
      [0-9]*)
        ### Add directory to list
        if [[ ${input} -le ${#auto_detected_dirs[@]} ]]; then
          CONFIG_FOLDER_LIST+=("${auto_detected_dirs[$((input - 1))]}")
          success_msg "Added ${auto_detected_dirs[$((input - 1))]}"
        else
          ### Invalid input
          deny_action
        fi
        ;;
      x | X)
        ### Stop adding direcories
        break
        ;;
      y | Y)
        for dir in "${auto_detected_dirs[@]}"; do
          CONFIG_FOLDER_LIST+=("${dir}")
          success_msg "Added ${dir}"
        done
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && input=""

  ### Add additional directories
  while true; do
    ### Prompt user for input
    input=""
    read -r -p "$(echo -e "${PURPLE}Do you want to add additional directories? [y|n] ${NC}")" -i "n" -e input
    ### Validate user input
    case ${input} in
      y | Y)
        ### Add directory to list
        input=""

        ### Prompt user for input
        read -r -p "$(echo -e "${PURPLE}Enter the path of config folder: ${NC}")" input
        ### Expand user input to full paths
        #!  Only if the user didn't input a full path
        if ! echo "${input}" | grep -q "^/"; then
          ### Check if ´~´ was input and replace it with ${HOME}
          if echo "${input}" | grep -q "^~"; then
            input=${input/\~/${HOME}}
          else
            ### Relative path detected
            #!  Prepend ${HOME} in the hope that the user set up klipper as a standard installation
            warning_msg "Relative path detected. Assuming relative to ${HOME}"
            input="${HOME}/${input}"
          fi
        fi

        ### Append input to the config folder list
        CONFIG_FOLDER_LIST+=("${input}")
        success_msg "${input} has been added to the list"

        ### Reset input to prevent duplicate entries
        input=""
        ;;
      n | N)
        ### Stop adding direcories
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && input=""
}
