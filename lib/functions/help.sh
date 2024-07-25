#!/bin/bash

i_dont_know_what_im_doing_here() {
  ### Default header for quick help menu
  #!  Dumb name because why not

  echo -e ""
  echo -e "${CYAN}       Welcome to the quick help       ${NC}"
  echo -e "${CYAN}Further documentation can be foud here:${NC}"
  echo -e "${WHITE}https://github.com/Low-Frequency/Klipper-Git-Backup/blob/main/docs/DOCUMENTATION.md${NC}"
  echo -e ""
}

help_main() {
  ### Prints the help screen for the main menu

  i_dont_know_what_im_doing_here

  echo -e "${BWHITE}Action                Description${NC}"
  echo -e "${PURPLE}Configure             ${WHITE}This will lead to a menu to configure the script${NC}"
  echo -e "                      ${WHITE}Further information can be called from there${NC}"
  echo -e "${PURPLE}Install               ${WHITE}This will install the script with the current configuration${NC}"
  echo -e "${PURPLE}Update                ${WHITE}This will update the script. Does nothing if no update is available${NC}"
  echo -e "${PURPLE}Backup                ${WHITE}This will perform a backup${NC}"
  echo -e "${PURPLE}Restore               ${WHITE}This will restore your config from a previous backup${NC}"
  echo -e "${PURPLE}Migrate to v2         ${WHITE}This will migrate your configuration to v2${NC}"
  echo -e "                      ${WHITE}Does nothing if you're already on v2${NC}"
  echo -e "${PURPLE}Uninstall             ${WHITE}This will remove the script and all of it's configuration${NC}"
}

help_config() {
  ### Prints the help screen for the config menu

  i_dont_know_what_im_doing_here

  echo -e "${BWHITE}Action                Description${NC}"
  echo -e "${PURPLE}Git                   ${WHITE}This will lead to a menu to configure GitHub options${NC}"
  echo -e "                      ${WHITE}Further information can be called from there${NC}"
  echo -e "${PURPLE}Log Rotation          ${WHITE}This will lead to a menu to configure when logs are deleted${NC}"
  echo -e "                      ${WHITE}Further information can be called from there${NC}"
  echo -e "${PURPLE}Scheduled Backups     ${WHITE}This will lead to a menu to configure the backup schedule${NC}"
  echo -e "                      ${WHITE}Further information can be called from there${NC}"
  echo -e "${PURPLE}Save Config           ${WHITE}This will save the current config${NC}"
  echo -e "${PURPLE}Show Config           ${WHITE}This will show the current config including unsaved changes${NC}"
  echo -e "${PURPLE}Refresh Menu          ${WHITE}This will reload the menu to update the status column${NC}"
}

help_advanced() {
  ### Prints the help screen for the advanced menu

  i_dont_know_what_im_doing_here

  echo -e "${BWHITE}Action                Description${NC}"
  echo -e "${PURPLE}Git Server            ${WHITE}You can specify a custom git server through this option${NC}"
  echo -e "                      ${RED}Be aware that this is an advanced configuration and I won't guarantee support for this${NC}"
  echo -e "${PURPLE}Organisation          ${WHITE}If your account belongs to an organisation, you can set that here${NC}"
  echo -e "                      ${RED}Be aware that this is an advanced configuration and I won't guarantee support for this${NC}"
  echo -e "${PURPLE}Refresh Menu          ${WHITE}This will reload the menu to update the status column${NC}"
}

help_schedule() {
  ### Prints the help screen for the backup schedule menu

  i_dont_know_what_im_doing_here

  echo -e "${BWHITE}Action                Description${NC}"
  echo -e "${PURPLE}Set Schedule          ${WHITE}You can configure the backup schedule here${NC}"
  echo -e "${PURPLE}Toggle schedule       ${WHITE}This will turn on/off the scheduled backups depending on the current config${NC}"
  echo -e "${PURPLE}Refresh Menu          ${WHITE}This will reload the menu to update the status column${NC}"
}

help_github() {
  ### Prints the help screen for the github menu

  i_dont_know_what_im_doing_here

  echo -e "${BWHITE}Action                Description${NC}"
  echo -e "${PURPLE}User                  ${WHITE}Set your GitHub username here${NC}"
  echo -e "${PURPLE}Mail                  ${WHITE}Set your mail address here${NC}"
  echo -e "${PURPLE}Default Branch        ${WHITE}This controls what your default branch will be${NC}"
  echo -e "                      ${WHITE}Leave it set to main if you didn't change it on GitHub${NC}"
  echo -e "${PURPLE}Repository            ${WHITE}Set the repository name here${NC}"
  echo -e "                      ${WHITE}Defaults to a set name, but feel free to change this${NC}"
  echo -e "${PURPLE}Config Folders        ${WHITE}This will try to detect your klipper instances${NC}"
  echo -e "                      ${WHITE}You can set additional folders after the auto detect${NC}"
  echo -e "                      ${WHITE}All folders configured will be backed up${NC}"
  echo -e "                      ${WHITE}Make sure to only input the printer_data folder${NC}"
  echo -e "                      ${WHITE}The script will automatically choose the config files for you${NC}"
  echo -e "${PURPLE}Toggle Backup         ${WHITE}This will turn on/off the backups depending on the current config${NC}"
  echo -e "${PURPLE}Advanced              ${WHITE}This will lead to an advanced config menu${NC}"
  echo -e "                      ${WHITE}Further information can be called from there${NC}"
  echo -e "                      ${RED}Be aware that support for this will be limited${NC}"
  echo -e "${PURPLE}Refresh Menu          ${WHITE}This will reload the menu to update the status column${NC}"
}

help_rotation() {
  ### Prints the help screen for the log rotation menu

  i_dont_know_what_im_doing_here

  echo -e "${BWHITE}Action                Description${NC}"
  echo -e "${PURPLE}Set Retention Time    ${WHITE}This controls how long logs are stored${NC}"
  echo -e "${PURPLE}Toggle Log Rotation   ${WHITE}This will turn on/off the log deletion depending on the current config${NC}"
  echo -e "${PURPLE}Refresh Menu          ${WHITE}This will reload the menu to update the status column${NC}"
}

help_restore() {
  ### Prints the help screen for the restore menu

  i_dont_know_what_im_doing_here

  echo -e "${PURPLE}This is a dynamic menu, so I can't give you explicit info to all entries${NC}"
  echo -e "${PURPLE}The menu is generated based on the printer_data folders you configured${NC}"
  echo -e "${PURPLE}Simply choose the instance you want to restore${NC}"
}
