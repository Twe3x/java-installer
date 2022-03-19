#!/usr/bin/env bash

# Colors
red="\e[0;91m"
green="\e[0;92m"
bold="\e[1m"
reset="\e[0m"


status(){
  clear
  echo -e $green$@'...'$reset
  sleep 1
}

runCommand(){
    COMMAND=$1

    if [[ ! -z "$2" ]]; then
      status $2
    fi

    eval $COMMAND;
    BASH_CODE=$?
    if [ $BASH_CODE -ne 0 ]; then
      echo -e "${red}An error occurred:${reset} ${white}${COMMAND}${reset}${red} returned${reset} ${white}${BASH_CODE}${reset}"
      exit ${BASH_CODE}
    fi
}

#install curl
runCommand "apt -y install curl" "install curl"


#get BashSelect
source <(curl -s https://raw.githubusercontent.com/GermanJag/BashSelect.sh/main/BashSelect.sh)
clear

export OPTIONS=("install Java" "change Java" "do nothing")

bashSelect

case $? in
     0 )
        bash <(curl -s https://raw.githubusercontent.com/Twe3x/java-installer/main/install.sh);;
     1 )
        clear
        runCommand "update-alternatives --config java";;
     2 )
        exit 0
esac