#!/bin/bash

activate_module(){
  MODULE="$1"
  echo -e "   ${WHITE}[${GREEN}\u2713${WHITE}] Activated ${MODULE}${NC}"
}

deactivate_module() {
  MODULE="$1"
  echo -e "   ${WHITE}[${RED}\u2717${WHITE}] Deactivated ${MODULE}${NC}"
}

deny_action() {
  echo -e "   ${WHITE}[${RED}\u126A0${WHITE}] ${RED}Unsupported action!${NC}"
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
  echo -e "[$(date '+%F %T')]: ${MSG}" | tee -a "$HOME/kgb-log/kgb-$(date +%F).log"
}
