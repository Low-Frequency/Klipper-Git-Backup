#!/bin/bash

quit_installer() {
  local SAVE_CHANGES
  while [[ $UNSAVED_CHANGES -ne 0 ]]
  do
    echo -e "${RED}You have not saved your changes!${NC}"
    read -p "$(echo -e "${CYAN}Save changes now? ${NC}")" SAVE_CHANGES
    case $SAVE_CHANGES in
      y|Y)
        save_config
        UNSAVED_CHANGES=0
        ;;
      n|N)
        echo -e "${RED}Not saving${NC}"
        UNSAVED_CHANGES=0
        ;;
      *)
        echo -e "   ${WHITE}[${RED}\u2717${WHITE}] ${RED}Unsupported action!${NC}"
        ;;
    esac
  done
  echo "Exiting"
  exit 0
}

activate_module(){
  MODULE="$1"
  echo -e "   ${WHITE}[${GREEN}\u2713${WHITE}] Activated ${MODULE}${NC}"
}

deactivate_module() {
  MODULE="$1"
  echo -e "   ${WHITE}[${RED}\u2717${WHITE}] Deactivated ${MODULE}${NC}"
}

deny_action() {
  echo -e "   ${WHITE}[${RED}\u2717${WHITE}] ${RED}Unsupported action!${NC}"
}

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
	write_line_to_config "GIT=${GIT}"
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

success_msg() {
  MSG="$1"
  echo -e "   ${WHITE}[${GREEN}\u2794${WHITE}] ${MSG}${NC}"
}

warning_msg() {
  MSG="$1"
  echo -e "   ${WHITE}[${YELLOW}\u26A0${WHITE}] ${MSG}${NC}"
}
