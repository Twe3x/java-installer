#!/bin/bash

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

jq --version
if [[ $? == 127  ]]; then  apt -y install jq; fi

#get BashSelect
source <(curl -s https://raw.githubusercontent.com/GermanJag/BashSelect.sh/main/BashSelect.sh)
clear

readarray -t VERSIONS <<<$(curl -s https://api.adoptium.net/v3/info/available_releases | jq '.available_releases[]')

export OPTIONS=(${VERSIONS[*]})

bashSelect

selectVersion=${VERSIONS[$?]}

downloadLink=$(curl -s "https://api.adoptium.net/v3/assets/feature_releases/${selectVersion}/ga?architecture=x64&heap_size=normal&image_type=jdk&os=linux&page=1&page_size=1&project=jdk&sort_method=DEFAULT&sort_order=DESC&vendor=eclipse" | jq '.[].binaries' | jq '.[].package.link')

javadir="/usr/lib/jvm/"
if [ ! -d "$javadir" ]; then
    runCommand "mkdir $javadir"
fi

tmpJavaDir="/tmp/java-installer/"
if [ ! -d "$tmpJavaDir" ]; then
    runCommand "mkdir $tmpJavaDir"
fi

runCommand "cd $tmpJavaDir"
runCommand "rm -rf $tmpJavaDir*"
runCommand "wget $downloadLink" "download Java SE $selectVersion"
runCommand "tar -xvzf *.tar.gz" "unpacking JDK"
runCommand "rm -rf *.tar.gz"

tmp=$(ls)
runCommand "mv $tmp java-$selectVersion-openjdk"

java=$(ls)

runCommand "mv $java $javadir"

runCommand "update-alternatives --install /usr/bin/java java $javadir$java/bin/java 1020"
runCommand "update-alternatives --install /usr/bin/javac javac $javadir$java/bin/javac 1020"

runCommand "update-alternatives --set java $javadir$java/bin/java"
runCommand "update-alternatives --set javac $javadir$java/bin/javac" "the installation was successful"
