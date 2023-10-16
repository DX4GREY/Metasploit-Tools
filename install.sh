#!/bin/bash
reset_color="\033[0m"
red_color="\033[31m"
green_color="\033[32m"
brown_color="\033[33m"
blue_color="\033[34m"

center_text() {
  local text="$1"
  local width="$2"
  
  local text_length=${#text}
  local padding=$((($width - $text_length) / 2))
  
  local left_padding=""
  local right_padding=""
  
  for ((i = 0; i < $padding; i++)); do
    left_padding="${left_padding} "
    right_padding="${right_padding} "
  done

  local centered_text="${left_padding}${text}${right_padding}"
  echo "$centered_text"
}

showTitle() {
    judul="$(center_text "$1" 42)"
    echo -e "
${green_color}┈┏━━━━━━┓     ${green_color}[${red_color}  __ __  ___  ___   ___            _      ${green_color}]${reset_color}
${green_color}┈┈▏╱╱╱╱▕      ${green_color}[${red_color} |  \  \/ __>| __> |_ _| ___  ___ | | ___ ${green_color}]${reset_color}
${green_color}┈┈┣━┳━┳┫      ${green_color}[${red_color} |     |\__ \| _>   | | / . \/ . \| |<_-< ${green_color}]${reset_color}
${green_color}┈━╋━┻━┻╋━     ${green_color}[${red_color} |_|_|_|<___/|_|    |_| \___/\___/|_|/__/ ${green_color}]${reset_color}
${green_color}┈╭┫▊┃┃▊┣╮┈${reset_color}╭╯  ${green_color}[ ${blue_color}Created By Dx4           ${red_color}©Copyright 2023 ${green_color}]${reset_color}
${green_color}┈┃┃▔╰╯▔┃┃${reset_color}╭╯   ${green_color}[                                          ${green_color}]
${green_color}┈╰┫┏━━${brown_color}▂▂▂█    ${green_color}[${reset_color}${judul}${green_color}]${reset_color}
${green_color}┈┈╭╰━━╯╮      
${green_color}┈┈╭╭╭╯╮╮ ${reset_color}"
}
clear
showTitle "Installation scripts"
echo
echo -n "Building scripts..."
if [ command -v shc ]; then
    shc -f main.sh -o msftools
fi
if [ -e main.sh.x.c ]; then
    rm -rf main.sh.x.c
    echo -e "\rBuilding scripts ${brown_color}[${green_color}√${brown_color}]${reset_color}"
else
    echo -e "\rBuilding scripts ${brown_color}[${red_color}X${brown_color}]${reset_color}"
    exit 1
fi
echo -n "Installing to path..."
if [ "$(uname -o)" = "Android" ]; then
    cp -f msftools $PREFIX/bin
    chmod +x $PREFIX/bin/msftools
    path="$PREFIX/bin/msftools"
else
    sudo cp -f msftools /usr/local/bin
    sudo chmod +x /usr/local/bin/msftools
    path="/usr/local/bin/msftools"
fi
rm -rf msftools
if [ -e $PREFIX/bin/msftools ]; then
    echo -e "\rInstalling to path ${brown_color}[${green_color}√${brown_color}]${reset_color}"
    echo "Just run : msftools"
else
    echo -e "\rInstalling to path ${brown_color}[${red_color}X${brown_color}]${reset_color}"
fi