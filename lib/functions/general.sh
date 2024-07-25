#!/bin/bash

activate_module() {
  ### Activates a function of the script

  local module="$1"
  echo -e "   ${WHITE}[${GREEN}\u2713${WHITE}] Activated ${module}${NC}"
}

deactivate_module() {
  ### Deactivates a function of the script

  local module="$1"
  echo -e "   ${WHITE}[${RED}\u2717${WHITE}] Deactivated ${module}${NC}"
}

deny_action() {
  ### Prints info about invalid input

  echo -e "   ${WHITE}[${RED}\u126A0${WHITE}] ${RED}Inavlid input!${NC}"
}

success_msg() {
  ### Prints a success message

  local msg="$1"
  echo -e "   ${WHITE}[${GREEN}\u2794${WHITE}] ${msg}${NC}"
}

warning_msg() {
  ### Prints a warning

  local msg="$1"
  echo -e "   ${WHITE}[${YELLOW}\u26A0${WHITE}] ${msg}${NC}"
}

error_msg() {
  ### Prints an error

  local msg="$1"
  echo -e "   ${WHITE}[${RED}\u26A0${WHITE}] ${msg}${NC}"
}

info_msg() {
  ### Prints info text

  local msg="$1"
  echo -e "   ${WHITE}[${PURPLE}\u24D8${WHITE}] ${msg}${NC}"
}

log_msg() {
  ### Writes a line to the log

  local msg="$1"
  echo -e "[$(date '+%F %T')]: ${msg}" | tee -a "${HOME}/kgb-data/log/kgb-$(date +%F).log"
}
