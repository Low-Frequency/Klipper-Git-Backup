#!/bin/bash

get_input() {
  TEXT="$1"
  read -p "$1 " INPUT
  echo "$INPUT"
}

check_yn() {
  ANSWER=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  case $ANSWER in
    y|n|yes|no)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

check_no() {
  ANSWER=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  case $ANSWER in
    n|no)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

check_int() {
  ANSWER=$1
  case $ANSWER in
    [0-9])
      return 1 ;;
    *)
      return 0 ;;
  esac
}

print_msg() {
  COLOR=$1
  MSG=$2
  case $COLOR in
    purple)
      echo -e "${PURPLE}${MSG}${NC}" ;;
    green)
      echo -e "${GREEN}${MSG}${NC}" ;;
    red)
      echo -e "${RED}${MSG}${NC}" ;;
    cyan)
      echo -e "${CYAN}${MSG}${NC}" ;;
		yellow)
			echo -e "${YELLOW}${MSG}${NC}" ;;
		none)
			echo -e "${NC}${MSG}${NC}" ;;
  esac
}

log_msg() {
  MSG="$1"
  echo "$MSG" | tee -a "$HOME/backup_log/$(date +%F).log"
}
