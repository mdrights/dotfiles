#!/bin/bash
## De-duplicate.sh: find out the duplicated files.
## Date: 2021.01.03


WORKDIR="/home/user/build/CURRENT"

cd $WORKDIR
FILES="$(find . -type f )"


FILELIST1=$(
    for file in $FILES; do
        APP=$(echo $file |awk -F"-" '{ print $1 }')
        echo $APP
    done )

FILELIST2=$(
    for file in $FILES; do
        APP=$(echo $file |awk -F"-" '{ print $1"-"$2 }')
        echo $APP
    done )


#DUP="$(echo -e "$FILELIST1" |sort |uniq -d)"
DUP="$(echo -e "$FILELIST1 \n $FILELIST2" |sort |uniq -d)"

echo "==== The Duplicated Files are: ===="
echo "$DUP"

exit

