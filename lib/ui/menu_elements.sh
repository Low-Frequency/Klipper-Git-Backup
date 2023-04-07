#!/bin/bash

menu_header() {
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|     ${PURPLE}~~~~~~~~~~~~~~~~~ [KGB] ~~~~~~~~~~~~~~~~${WHITE}     |${NC}"
  echo -e "${WHITE}|     ${PURPLE}~~~~~~~~~~ Klipper Git Backup ~~~~~~~~~~${WHITE}     |${NC}"
  echo -e "${WHITE}|     ${PURPLE}~~~~~~~~~~~~~~~~ ${WHITE}${VERSION}${PURPLE} ~~~~~~~~~~~~~~~~${WHITE}     |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
}

### Unicode Chars:
### \u00AB: Double back Arrow
### \u2717: Cross mark
menu_footer() {
  echo -e "${WHITE}|     ${YELLOW}B) \u00AB Back${WHITE}                      ${RED}Q) \u2717 Quit${WHITE}     |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
}

menu_info() {
  echo -e "${WHITE}|     ${BOLD}Status Info${WHITE}                                  |${NC}"
  echo -e "${WHITE}|     ${RED}Red               ${WHITE}Disabled                   |${NC}"
  echo -e "${WHITE}|     ${YELLOW}Yellow            ${WHITE}Not Configured             |${NC}"
  echo -e "${WHITE}|     ${GREEN}Green             ${WHITE}Configured and enabled     |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
}

advanced_info() {
  echo -e "${WHITE}|                       ${BOLD}INFO${WHITE}                       |${NC}"
  echo -e "${WHITE}| The URLs to the repos are generated like this:   |${NC}"
  echo -e "${WHITE}| https://base_url/namespace/repo.git              |${NC}"
  echo -e "${WHITE}| git@base_url:namespace/repo.git                  |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
}
