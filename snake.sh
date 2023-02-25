#!/usr/bin/env bash

good_game=(
    '                                                 '
    '                G A M E  O V E R !               '
    '                                                 '
    '                   Score:                        '
    '          press   q   to quit                    '
    '          press   n   to start a new game        '
    '          press   c   to change the speed        '
    '                                                 '
);

game_start=(
    '                                                 '
    '                ~~~ S N A K E ~~~                '
    '                                                 '
    '               Author:  Razvan Trombitas         '
    '         space or enter   pause/play             '
    '         q                quit at any time       '
    '         c                change the speed       '
    '                                                 '
    '         Press <Enter> to start the game         '
    '                                                 '
);

snake_exit() {  
    stty echo;  
    tput rmcup; 
    tput cvvis; # unhide cursor
    exit 0;
}

draw_gui() {                                
    clear;
    color="\033[34m*\033[0m";
    for (( i = 0; i < $1; i++ )); do
        echo -ne "\033[$i;0H${color}";
        echo -ne "\033[$i;$2H${color}";
    done

    for (( i = 0; i <= $2; i++ )); do
        echo -ne "\033[0;${i}H${color}";
        echo -ne "\033[$1;${i}H${color}";
    done

    ch_speed 0;
    echo -ne "\033[$Lines;$((yscore-10))H\033[36mScores: 0\033[0m";
    echo -en "\033[$Lines;$((Cols-50))H\033[33mPress <space> or enter to pause game\033[0m";
}

snake_init() {
    Lines=`tput lines`; Cols=`tput cols`;     # get the length and the width of the screen
    xline=$((Lines/2)); ycols=4;              # starting position
    xscore=$Lines;      yscore=$((Cols/2));   # coordinates of the printed line
    xcent=$xline;       ycent=$yscore;        # center pointe
    xrand=0;            yrand=0;              
    sumscore=0;         liveflag=1;           # total  points and point presence markers
    sumnode=0;          foodscore=0;          # The total number of nodes and points to be lengthened
    
    snake="0000 ";                            # initialize
    pos=(right right right right right);      # direction of the start point
    xpt=($xline $xline $xline $xline $xline); # The x-coordinate of each node to start with
    ypt=(5 4 3 2 1);                          # The y-coordinate of each node to start with
    speed=(0.05 0.1 0.15);  spk=${spk:-1};    # speed default speed

    draw_gui $((Lines-1)) $Cols
}

game_pause() {                                
    echo -en "\033[$Lines;$((Cols-50))H\033[33mGame paused, Use space or enter key to continue\033[0m";
    while read -n 1 space; do
        [[ ${space:-enter} = enter ]] && \
            echo -en "\033[$Lines;$((Cols-50))H\033[33mPress <space> or enter to pause game           \033[0m" && return;
        [[ ${space:-enter} = q ]] && snake_exit;
    done
}

# Update the coordinates of each node
update() {                                   
    case ${pos[$1]} in
        right) ((ypt[$1]++));;
         left) ((ypt[$1]--));;
         down) ((xpt[$1]++));;
           up) ((xpt[$1]--));;
    esac
}

ch_speed() {                                 
     [[ $# -eq 0 ]] && spk=$(((spk+1)%3));
     case $spk in
         0) temp="Fast  ";;
         1) temp="Medium";;
         2) temp="Slow  ";;
     esac
     echo -ne "\033[$Lines;3H\033[33mSpeed: $temp\033[0m";
}

# update direction
Go() {                                   
    case ${key:-enter} in
        s|S) [[ ${pos[0]} != "up"    ]] && pos[0]="down";;
        w|W) [[ ${pos[0]} != "down"  ]] && pos[0]="up";;
        a|A) [[ ${pos[0]} != "right" ]] && pos[0]="left";;
        d|D) [[ ${pos[0]} != "left"  ]] && pos[0]="right";;
        c|C) ch_speed;;
        q|Q) snake_exit;;
      enter) game_pause;;
    esac
}

add_node() {                                 
    snake="0$snake";
    pos=(${pos[0]} ${pos[@]});
    xpt=(${xpt[0]} ${xpt[@]});
    ypt=(${ypt[0]} ${ypt[@]});
    update 0;

    local x=${xpt[0]} y=${ypt[0]}
    (( ((x>=$((Lines-1)))) || ((x<=1)) || ((y>=Cols)) || ((y<=1)) )) && return 1; # hit the wall

    for (( i = $((${#snake}-1)); i > 0; i-- )); do
        (( ${xpt[0]} == ${xpt[$i]} && ${ypt[0]} == ${ypt[$i]} )) && return 1; #crashed
    done

    echo -ne "\033[${xpt[0]};${ypt[0]}H\033[32m${snake[@]:0:1}\033[0m";
    return 0;
}

# generate random points and random numbers
mk_random() {                               
    xrand=$((RANDOM%(Lines-3)+2));
    yrand=$((RANDOM%(Cols-2)+2));
    foodscore=$((RANDOM%9+1));
    echo -ne "\033[$xrand;${yrand}H$foodscore";
    liveflag=0;
}

new_game() {                              
    snake_init;
    while true; do
        read -t ${speed[$spk]} -n 1 key;
        [[ $? -eq 0 ]] && Go;

        ((liveflag==0)) || mk_random;
        if (( sumnode > 0 )); then
            ((sumnode--));
            add_node; (($?==0)) || return 1;
        else
            update 0; 
            echo -ne "\033[${xpt[0]};${ypt[0]}H\033[32m${snake[@]:0:1}\033[0m";

            for (( i = $((${#snake}-1)); i > 0; i-- )); do
                update $i;
                echo -ne "\033[${xpt[$i]};${ypt[$i]}H\033[32m${snake[@]:$i:1}\033[0m";

                (( ${xpt[0]} == ${xpt[$i]} && ${ypt[0]} == ${ypt[$i]} )) && return 1; #crashed
                [[ ${pos[$((i-1))]} = ${pos[$i]} ]] || pos[$i]=${pos[$((i-1))]};
            done
        fi

        local x=${xpt[0]} y=${ypt[0]}
        (( ((x>=$((Lines-1)))) || ((x<=1)) || ((y>=Cols)) || ((y<=1)) )) && return 1; # hit the wall

        (( x==xrand && y==yrand )) && ((liveflag=1)) && ((sumnode+=foodscore)) && ((sumscore+=foodscore));

        echo -ne "\033[$xscore;$((yscore-2))H$sumscore";
    done
}

print_good_game() {
    local x=$((xcent-4)) y=$((ycent-25))
    for (( i = 0; i < 8; i++ )); do
        echo -ne "\033[$((x+i));${y}H\033[45m${good_game[$i]}\033[0m";
    done
    echo -ne "\033[$((x+3));$((ycent+1))H\033[45m${sumscore}\033[0m";
}

print_game_start() {
    snake_init;

    local x=$((xcent-5)) y=$((ycent-25))
    for (( i = 0; i < 10; i++ )); do
        echo -ne "\033[$((x+i));${y}H\033[45m${game_start[$i]}\033[0m";
    done

    while read -n 1 anykey; do
        [[ ${anykey:-enter} = enter ]] && break;
        [[ ${anykey:-enter} = q ]] && snake_exit;
        [[ ${anykey:-enter} = s ]] && ch_speed;
    done
    
    while true; do
        new_game;
        print_good_game;
        while read -n 1 anykey; do
            [[ $anykey = n ]] && break;
            [[ $anykey = q ]] && snake_exit;
        done
    done
}

game_main() {
    trap 'snake_exit;' SIGTERM SIGINT; 
    stty -echo;                               
    tput civis;                               # hide the cursor
    tput smcup; clear;                        # save the screen and then clear 
    print_game_start;                         
}

game_main;
