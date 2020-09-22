#!/bin/bash
name=$(basename $0)

if [[ ! $1 ]]; then
    echo ""
    echo "Plays the mp3 from the directory and allows to decide if to delete or keep afterwards"
    echo ""
    echo "$name mp3_dir_name"
    echo ""
    exit 1
fi

if [[ -d $1 ]]; then
    dir=$1
    dir2=${1}_ok

    if [[ ! -d $dir2 ]]; then
        mkdir $dir2
    fi

    IFS=$'\n'

    files=($dir/*)

    while [ $files ]; do
        count=${#files[*]}
        clear
        echo -e "\e[32m--------------------------------------------------------\e[39m"
        echo -e "$count files to process"
        echo -e ""
        mp ${files[0]}
        echo ""
        echo -n "[E]dit, [R]eplay, [D]elete, [K]eep, [Q]uit ? : "
        read -N 1 answ
        echo ""

        case $answ in
        [d])

            echo -n "Delete \"${files[0]}\" ? "
            read -N 1 answ2

            if [[ "$answ2" == "y" ]]; then
                rm ${files[0]}
                files=(${files[@]:1:${#files[@]}})
            fi
            ;;

        [D])
            rm ${files[0]}
            files=(${files[@]:1:${#files[@]}})
            ;;
        [eE])
            ocenaudio "${files[0]}"
            ;;
        [kK])
            mv -i ${files[0]} $dir2/
            files=(${files[@]:1:${#files[@]}})
            ;;
        [rR])
            ;;
        [qQ])
            echo ""
            exit 0
            ;;
        esac
    done
fi
