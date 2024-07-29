#!/bin/bash

menu_header() {
  ### Default menu header
  #!  Version line is dynamically generated based on the length of the version

  local ver
  local version_length
  local version_string

  ver="Version ${VERSION}"
  version_length="${#ver}"

  ### Set the version string to a odd number of characters
  if ((version_length % 2)); then
    version_string=" ${WHITE}${ver}${PURPLE} "
  else
    version_string=" ${WHITE}${ver}${PURPLE}  "
  fi

  ### Fill up version string to specified number of characters
  for ((i = version_length; i < 38; i = i + 2)); do
    version_string="~${version_string}~"
  done

  ### Limit to 40 characters
  #!  Actually limits to 60 characters, but there are 20 non printable characters
  #!  These characters count to the length of the string while not printed
  #!  If this doesn't work, remove the color from the string and limit to 40
  version_string="$(echo "${version_string}" | grep -Eo "^.{1,60}")"

  ### Print menu header
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|     ${PURPLE}~~~~~~~~~~~~~~~~~ ${WHITE}[KGB]${PURPLE} ~~~~~~~~~~~~~~~~${WHITE}     |${NC}"
  echo -e "${WHITE}|     ${PURPLE}~~~~~~~~~~ ${WHITE}Klipper Git Backup${PURPLE} ~~~~~~~~~~${WHITE}     |${NC}"
  echo -e "${WHITE}|     ${PURPLE}${version_string}     ${WHITE}|${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
}

menu_footer() {
  ### Menu footer with explanation for menu functions
  #!  Used unicode characters:
  #!  \u00AB: Double back Arrow
  #!  \u2717: Cross mark
  #!  \u24D8: Info i in circle

  ### Print menu footer
  echo -e "${WHITE}|                    H) ${INFO}  Help                    |${NC}"
  echo -e "${WHITE}|     ${YELLOW}B) ${BACK} Back${WHITE}                      ${RED}Q) ${CROSS} Quit${WHITE}     |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
}

menu_info() {
  ### Info section of the menu
  #!  Displays all possible status colors and their meaning

  ### Print info menu
  echo -e "${WHITE}|                   ${BWHITE}Status Info${WHITE}                    |${NC}"
  echo -e "${WHITE}|     [${RED}${CROSS}${WHITE}]               Disabled                   |${NC}"
  echo -e "${WHITE}|     [${YELLOW}${EXCLM}${WHITE}]               Not Configured             |${NC}"
  echo -e "${WHITE}|     [${GREEN}${CHECK}${WHITE}]               Configured and enabled     |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
}

advanced_info() {
  ### Info section for the advanced menu
  #!  Shows help for configuring self hosted git instances

  ### Print advanced info menu
  echo -e "${WHITE}|                       ${BWHITE}INFO${WHITE}                       |${NC}"
  echo -e "${WHITE}| The URLs to the repos are generated like this:   |${NC}"
  echo -e "${WHITE}| git@base_url:namespace/repo.git                  |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
}
