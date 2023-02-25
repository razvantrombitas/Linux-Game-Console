#!/bin/bash

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Operating System: Debian GNU/Linux 11 (bullseye) Kernel: Linux 5.10.92-v8+ Architecture: arm64"
TITLE="Game Console"
MENU="Please choose one of the following options:"

OPTIONS=(1 "Blitz"
         2 "Snake"
         3 "Quit")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
while :
do 
	case $CHOICE in
        1)
            bash blitz.sh
            exec $0
            ;;
        2)
            bash snake.sh
            exec $0
            ;;
            
        3) 	echo "Thank you for playing"
			exit
			;;
        
	esac
done 
