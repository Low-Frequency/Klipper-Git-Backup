#!/bin/bash

GITHUB_UI_CONTENT=(
  "Username"
  "Mail"
  "SSH_Setup"
  "Repositories"
  "Config_Folders"
  "Default_Branch"
  "Enable_Backups"
  "Disable_Backups"
  "Clear_Screen"
)

github_ui() {
  clear
  ui_script_title "KGB" "Klipper Git Backup"
  ui_header "GitHub Config"
  ui_body "${GITHUB_UI_CONTENT[@]}"
  ui_footer
}

github_actions() {
  while true
  do
    ACTION=$(echo $(get_input "Choose an action:") | tr '[:upper:]' '[:lower:]')
    case $ACTION in
      c)
        end_script ;;
      b)
        break ;;
      1)
        GITHUB_USER=$(get_input "Please enter your GitHub Username:") ;;
      2)
        GITHUB_MAIL=$(get_input "Please enter your Mail Address:") ;;
      3)
        setup_ssh ;;
      4)
        if [ -z ${REPO_COUNT+x} ]
        then
          while check_int "${REPO_COUNT}"
          do
            REPO_COUNT=$(get_input "How many Instances should be backed up?")
          done
        else
          print_msg none "Number of instances was set to ${REPO_COUNT}"
        fi
        COUNTER=0
        while [[ $COUNTER -ne $REPO_COUNT ]]
        do
          REPO_LIST+=($(get_input "Please enter the URLs to your Repos one at a time:"))
          COUNTER=$(( COUNTER + 1 ))
        done ;;
      5)
        if [ -z ${REPO_COUNT+x} ]
        then
          while check_int "${REPO_COUNT}"
          do
            REPO_COUNT=$(get_input "How many Instances should be backed up?")
          done
        else
          print_msg none "Number of instances was set to ${REPO_COUNT}"
        fi
        COUNTER=0
        while [[ $COUNTER -ne $REPO_COUNT ]]
        do
          CONFIG_FOLDER_LIST+=($(get_input "Please enter the full paths to your config folders one at a time:"))
          COUNTER=$(( COUNTER + 1 ))
        done ;;
      6)
        print_msg purple "The default branch is set to main"
        print_msg cyan "The current branch is ${GITHUB_BRANCH}"
        GITHUB_BRANCH=$(get_input "Press enter to use the default, or provide a different value:")
        GITHUB_BRANCH=${GITHUB_BRANCH:-main} ;;
      7)
        print_msg green "Backups enabled"
        GIT=1 ;;
      8)
        print_msg red "Backups disabled"
        GIT=0 ;;
      9)
        github_ui ;;
      *)
        ;;
    esac
  done
}
