#!/bin/bash

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

add_config_folder() {
  ### Add config folders to the list

  local input

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
  echo -e "${PURPLE}Which folder should be included in the backup?${NC}"
  echo -e "${PURPLE}Choose only one per prompt${NC}"
  echo -e "${PURPLE}'all' for all detected folders${NC}"
  echo -e "${PURPLE}'stop' to stop adding folders${NC}"
  while true; do
    ### Prompt user for input
    read -r -p "$(echo -e "${PURPLE}Add folder: ${NC}")" -i "all" -e input
    ### Validate user input
    case ${input} in
      [0-9]*)
        ### Add directory to list
        #!  First check if the input is in the range of the array index
        if [[ ${input} -le ${#auto_detected_dirs[@]} ]]; then
          ### Set internal field separator to something weird that should not be in the name of a direcory
          IFS="%"
          ### Convert the CNONFIG_FOLDER_LIST array to a single string with the elements separated by IFS
          #!  Append and prepend IFS to make checking easier
          #!  Compare string with user input
          if [[ "${IFS}${CONFIG_FOLDER_LIST[*]}${IFS}" =~ ${IFS}${auto_detected_dirs[$((input - 1))]}${IFS} ]]; then
            ### Match found, so dir already exists
            warning_msg "Selected folder already exists in config"
            ### Reset IFS to not mess with other stuff
            unset IFS
          else
            ### No match found, so add the dir to the array
            #!  Reset IFS to not mess with other stuff
            unset IFS
            ### Append dir to array
            CONFIG_FOLDER_LIST+=("${auto_detected_dirs[$((input - 1))]}")
            success_msg "Added ${auto_detected_dirs[$((input - 1))]}"
            UNSAVED_CHANGES=1
          fi
        else
          ### Invalid input
          deny_action
        fi
        ;;
      stop)
        ### Stop adding direcories
        break
        ;;
      all)
        ### Loop over all auto detected instances
        for dir in "${auto_detected_dirs[@]}"; do
          ### Set internal field separator to something weird that should not be in the name of a direcory
          IFS="%"
          ### Convert the CNONFIG_FOLDER_LIST array to a single string with the elements separated by IFS
          #!  Append and prepend IFS to make checking easier
          #!  Compare string with user current dir
          if [[ "${IFS}${CONFIG_FOLDER_LIST[*]}${IFS}" =~ ${IFS}${dir}${IFS} ]]; then
            ### Match found, so dir already exists
            warning_msg "Selected folder already exists in config"
            ### Reset IFS to not mess with other stuff
            unset IFS
          else
            ### Reset IFS to not mess with other stuff
            unset IFS
            ### Append dir to array
            CONFIG_FOLDER_LIST+=("${dir}")
            success_msg "Added ${dir}"
            UNSAVED_CHANGES=1
          fi
        done
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && input=""
}

add_additional_dirs() {
  ### Add additional directories to config folder list

  local input

  ### Loop until user input is valid
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
        #!  Set internal field separator to something weird that should not be in the name of a direcory
        IFS="%"
        ### Convert the CNONFIG_FOLDER_LIST array to a single string with the elements separated by IFS
        #!  Append and prepend IFS to make checking easier
        #!  Compare string with user current dir
        if [[ "${IFS}${CONFIG_FOLDER_LIST[*]}${IFS}" =~ ${IFS}${input}${IFS} ]]; then
          ### Match found, so dir already exists
          warning_msg "Selected folder already exists in config"
          ### Reset IFS to not mess with other stuff
          unset IFS
        else
          ### Reset IFS to not mess with other stuff
          unset IFS
          ### Append input to array
          CONFIG_FOLDER_LIST+=("${input}")
          success_msg "Added ${input}"
          UNSAVED_CHANGES=1
        fi

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

remove_config_folder() {
  ### Removes config folders from list

  local input
  local del_dir

  ### Loop until user input is valid
  while true; do
    ### Print all current folders
    info_msg "The following folders are currently in config:"
    for i in "${!CONFIG_FOLDER_LIST[@]}"; do
      echo -e "$((i + 1))) ${CONFIG_FOLDER_LIST[${i}]}"
    done
    ### Prompt user for input
    echo -e "${PURPLE}'stop' to stop removing folders${NC}"
    read -r -p "$(echo -e "${PURPLE}Which folder do you want to remove? ${NC}")" input
    ### Validate user input
    case ${input} in
      [0-9]*)
        if [[ ${input} -le ${#auto_detected_dirs[@]} ]]; then
          ### Loop over all folders
          #!  Skip input
          for i in "${!CONFIG_FOLDER_LIST[@]}"; do
            ### Compare current index with user input
            if [[ ${i} -ne $((input - 1)) ]]; then
              ### Current insed not equal to user input
              #!  Append value to temporary array
              tmp_array+=("${CONFIG_FOLDER_LIST[${i}]}")
            else
              ### Current index matches input
              #!  Save value for output message
              del_dir="${CONFIG_FOLDER_LIST[${i}]}"
            fi
          done
          ### Reassign CONFIG_FOLDER_LIST with temporary array
          CONFIG_FOLDER_LIST=("${tmp_array[@]}")
          success_msg "Removed ${del_dir} from backed up folders"
          UNSAVED_CHANGES=1
        else
          ### Invalid input
          deny_action
        fi
        ;;
      stop)
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && input=""
}

config_folders() {
  ### Configure folders to be backed up

  local input

  ### Loop until user input is valid
  while true; do
    ### Prompt user for input
    read -r -p "$(echo -e "${PURPLE}Do you want to add or remove folders from the config? ${NC}")" -i "add" -e input
    ### Validate user input
    case ${input} in
      add)
        ### Add auto detected dirs
        add_config_folder
        ### Add user input dirs
        add_additional_dirs
        break
        ;;
      remove)
        ### Remove dirs
        remove_config_folder
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && input=""
}
