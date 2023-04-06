#!/bin/bash

quit_installer() {
  if [[ $UNSAVED_CHANGES -ne 0 ]]
  then
    while true
    do
      warning_msg "You have config changes pending!"
      read -p "$(echo -e "${CYAN}Save changes now? ${NC}")" SAVE_CHANGES
      case $SAVE_CHANGES in
        y|Y)
          save_config
          UNSAVED_CHANGES=0
          break
          ;;
        n|N)
          warning_msg "Your changes will be lost!"
          while true
          do
            read -p "$(echo -e "${CYAN}Continue? ${NC}")" LOOSE_CHANGES
            case $LOOSE_CHANGES in
              y|Y)
                warning_msg "Discarding changes"
                break
                ;;
              n|N)
                success_msg "Resuming"
                return 0
                ;;
              *)
                deny_action
                ;;
            esac
          done
          break
          ;;
        *)
          deny_action
          ;;
      esac
    done
  fi
  success_msg "Exiting"
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

success_msg() {
  MSG="$1"
  echo -e "   ${WHITE}[${GREEN}\u2794${WHITE}] ${MSG}${NC}"
}

warning_msg() {
  MSG="$1"
  echo -e "   ${WHITE}[${YELLOW}\u26A0${WHITE}] ${MSG}${NC}"
}

error_msg() {
  MSG="$1"
  echo -e "   ${WHITE}[${RED}\u26A0${WHITE}] ${MSG}${NC}"
}

info_msg() {
  MSG="$1"
  echo -e "   ${WHITE}[${PURPLE}\u24D8${WHITE}] ${MSG}${NC}"
}

log_msg() {
  MSG="$1"
  echo -e "[$(date '+%F %T')]: ${MSG}" | tee -a "$HOME/kgb-logs/kgb-$(date +%F).log"
}
