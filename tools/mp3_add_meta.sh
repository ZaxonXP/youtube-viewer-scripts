#!/bin/bash
genre=$*

rename -e 's/feat\./feat/' *.mp3

file=$(mktemp)
ls -1 *.mp3 > $file
total=$(cat $file | wc -l)

data=$(pwd | rev | cut -d/ -f1 | rev)
year=$(echo $data | cut -d. -f1)
album=$(echo $data | cut -d. -f2)

if [ -v DEBUG ]; then 
    echo DATA  = \"$data\"
    echo YEAR  = \"$year\"
    echo ALBUM = \"$album\"
fi

# check if year is a number
[[ $year =~ ^[0-9]+$ ]] && year=$year || year=""

data=$(pwd | rev | cut -d/ -f2 | rev)
artist=$data
count=0
options="--remove-all"

if [ -v DEBUG ]; then 
    echo DATA 2  = \"$data\"
    echo YEAR 2  = \"$year\"
    echo ALBUM 2 = \"$album\"
fi

while IFS=. read -r f1 f2 f3
do
    name=${f1}.${f2}.${f3}
    count=$(( $count + 1 ))

    if [ -v DEBUG ]; then 
        echo -e "F1 = $f1\nF2 = $f2\nF3 = $f3\n"
    fi

    # If there only 2 parts, then skip the year.
    if [[ "$f3" == "" ]]; then

        name=${name%.}

        eyeD3 $options -N $total -n $count -t "$f1" -a "$artist" -A "$album" -G "$genre" "$name"
    else

        if [[ "$year" != "" ]]; then
            eyeD3 $options -N $total -n $f1 -t "$f2" -a "$artist" -A "$album" -Y $year --recording-date=$year -G "$genre" "$name"
        else

            if [[ "$album" == "Singles" ]]; then
                eyeD3 $options -N $total -n $count -t "$f2" -a "$artist" -A "$artist - $album" -G "$genre" -Y $f1 --recording-date=$f1 "$name"
            else
                eyeD3 $options -N $total -n $f1 -t "$f2" -a "$artist" -A "$album" -G "$genre" "$name"
            fi
        fi
    fi

done < "$file"
rm $file
