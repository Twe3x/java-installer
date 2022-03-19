#!/usr/bin/env bash

#"curl -s https://jdk.java.net/java-se-ri/18 | grep -m 1 -o "se-ri/......" | sed "s/se-ri\///g" | sed "s/\"//g" | sed "s/>Jav//g" | sed "s/>Ja//g""

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

#get BashSelect
source <(curl -s https://raw.githubusercontent.com/GermanJag/BashSelect.sh/main/BashSelect.sh)
clear

readarray -t VERSIONS <<<$(curl -s https://jdk.java.net/java-se-ri/18 | grep -m 1 -o "se-ri/......" | sed "s/se-ri\///g" | sed "s/\"//g" | sed "s/>Jav//g" | sed "s/>Ja//g")

export OPTIONS=(${VERSIONS[*]})

bashSelect

selectVersion=${VERSIONS[$?]}

downloadLink=$(curl -s https://jdk.java.net/java-se-ri/$selectVersion | grep -m 1 -o "https://download.java.net/openjdk/jdk.*linux.*.gz" | sed "s/>//g" | sed "s/;//g" | sed "s/\"//g")

javadir="/usr/lib/jvm/"
if [ !-d "$javadir" ]; then
    runCommand "mkdir $javadir"
fi

tmpJavaDir="/tmp/java-installer/"
if [ !-d "$tmpJavaDir" ]; then
    runCommand "mkdir $tmpJavaDir"
fi

runCommand "cd $tmpJavaDir"
runCommand "rm -rf $tmpJavaDir*"
runCommand "wget $downloadLink" "download Java SE $selectVersion"
runCommand "tar -xvzf *.tar.gz" "unpacking JDK"
runCommand "rm -rf *.tar.gz"

java=$(ls)

runCommand "mv $java $javadir"

runCommand "update-alternatives --install /usr/bin/java java $javadir$java/bin/java 1"

runCommand "update-alternatives --config java" "the installation was successful"