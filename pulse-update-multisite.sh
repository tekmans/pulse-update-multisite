#!/bin/bash

#
# Written by Yvan Manon (Tekmans) <tekmans@no-log.org>
#

if [[ $1 == "-h" || $1 == "--help" || $# -eq 0 ]]; then
  echo -e "\n"
  echo "Name: `basename $0`"
  echo "Usage: Help to update your Pulse multisite installation and execute remote command"
  echo -e "\nSample : `basename $0` upgrade"
  echo "Sample : `basename $0` execute command"
  echo -e "\n"
  exit 0
fi

colored_echo() {
    local color=$1;
    if ! [[ $color =~ '^[0-9]$' ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        magenta) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    tput setaf $color;
    echo "${@:2}";
    tput sgr0;
}

# List all Pulse server 
pserver=(`cat /etc/mmc/pulse2/package-server/package-server.ini.local | grep package_mirror_target | sed 's/package_mirror_target = //'`)

upgrade () {
        for m in "${pserver[@]}"
        do
                colored_echo blue           "######################### Update server : ${m} ################"
                ssh -t ${m} "apt-get -qq update"
                ssh -t ${m} "TERM=$TERM DEBIAN_FRONTEND=dialog apt-get -qq -y dist-upgrade"
                if [[ $? == 0 ]]; then
                        colored_echo yellow "######################### Need attention ###############################"
                        ssh -t ${m} "find /etc/ -name '*.dpkg-dist' -exec ls {} \;"
                        colored_echo green  "######################### Update serve Done ############################"
                        echo ""
                        echo ""
                else
                        colored_echo red    "######################### Update server : ${m} Failed ##################"
                        ssh -t ${m} "find /etc/ -name '*.dpkg-dist' -exec ls {} \;"
                fi
        done
}
execute () {
        for m in "${pserver[@]}"
        do
                colored_echo blue           "######################### Execute "$1" on ${m} ################"
                ssh -t ${m} "$1" 2> /dev/null
        done
}

if [ $1 == "upgrade" ]; then
        upgrade
        elif [ $1 == "execute" ]; then
        echo "EXECUTE"
        else
        exit 0
fi
