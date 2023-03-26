#!/bin/bash

DIVIDER_LENGTH=50

ui_divider() {
  TYPE="$1"
  case $TYPE in
    empty)
      DIVIDER=" "
      EDGE="|" ;;
    middle)
      DIVIDER="-"
      EDGE="|" ;;
    normal)
      DIVIDER="-"
      EDGE="+" ;;
    strong)
      DIVIDER="="
      EDGE="+" ;;
  esac
  echo -ne "${NC}${EDGE}"
  for (( i=0; i<=$DIVIDER_LENGTH; i++ ))
  do
    echo -ne "${NC}${DIVIDER}"
  done
  echo -e "${NC}${EDGE}"
}

ui_title() {
  TITLE="$1"
  TITLE_LENGTH="${#TITLE}"
  SPACES=$(( DIVIDER_LENGTH - TITLE_LENGTH - 1 ))
  SPACE_START=$(( SPACES / 2 ))
  echo -ne "${NC}|"
  if [[ $(( SPACE_START * 2 )) -ne $SPACES ]]
  then
    SPACE_END=$(( SPACE_START + 1 ))
  else
    SPACE_END="${SPACE_START}"
  fi
  for (( i=0; i<=$SPACE_START; i++ ))
  do
    echo -n " "
  done
  echo -ne "${NC}${TITLE}${NC}"
  for (( i=0; i<=$SPACE_END; i++ ))
  do
    echo -n " "
  done
  echo -e "${NC}|"
}

ui_header() {
  HEADER="$1"
  ui_divider strong
  ui_title "${HEADER}"
  ui_divider strong
}

ui_body() {
  CONTENTS=($@)
  COUNT=1
  ui_divider empty
  for CONTENT in "${CONTENTS[@]}"
  do
    CONTENT_LENGTH="${#CONTENT}"
    SPACES=$(( DIVIDER_LENGTH - CONTENT_LENGTH - 4 ))
    echo -ne "${NC}| ${COUNT}: ${CONTENT}"
    for (( i=0; i<=$SPACES; i++ ))
    do
      echo -n " "
    done
    echo -e "${NC}|"
    COUNT=$(( COUNT + 1 ))
  done
  ui_divider empty
  ui_divider normal
}

ui_footer() {
  BACK="b: Back"
  CANCEL="c: Cancel"
  LEN_BACK="${#BACK}"
  LEN_CANCEL="${#CANCEL}"
  SPACES=$(( DIVIDER_LENGTH - LEN_BACK - LEN_CANCEL - 2 ))
  echo -ne "${NC}| ${YELLOW}${BACK}${NC}"
  for (( i=0; i<=$SPACES; i++ ))
  do
    echo -n " "
  done
  echo -e "${RED}${CANCEL}${NC} |"
  ui_divider normal
}
