#!/usr/bin/env bash
# Read and parse the json format messages pulled from signal-cli.
# This needs jq tool and Bash; Some commands need the BSD(POSIX) version.
# DATE  2021-09-28

set -eu

JQ=$(which jq)
MSG_FILE="/tmp/signal.msg"
gotcha=0

Parse_Group() {
    GROUP_FILE="$HOME/src/Signal/signal.groups.json"
    GROUP_ID=($(cat ${GROUP_FILE} | jq '.[].id'))
    GROUP_NAME="$(cat ${GROUP_FILE} | jq '.[].name')"
    GROUP_NAME=($(echo "$GROUP_NAME" |tr ' ' '-'))

    #echo ${GROUP_ID[@]}
    #echo ${GROUP_NAME[@]}
}
Parse_Group


echo "===== Start Parsing Messages ====="
echo

MSG_SOURCE=($(cat ${MSG_FILE} | $JQ '.envelope.source'))
#echo ${MSG_SOURCE[@]}

MSG_TIMESTAMP=($(cat ${MSG_FILE} | $JQ '.envelope.timestamp'))
#echo ${MSG_TIMESTAMP[@]}

MSG_BODY="$(cat ${MSG_FILE} | $JQ '.envelope.dataMessage.message')"
MSG_BODY_NEW=($(echo "$MSG_BODY" |tr ' ' '-'))
#echo "${MSG_BODY}"
#echo "${MSG_BODY_NEW[@]}"

MSG_GROUP=($(cat ${MSG_FILE} | $JQ '.envelope.dataMessage.groupInfo.groupId'))
#echo ${MSG_GROUP[@]}
#echo

Output() {
        
    for i in ${!MSG_BODY_NEW[@]}; do
        if [[ ${MSG_BODY_NEW[i]} == "null" ]];then
            continue
        fi
        echo ">> FROM: ${MSG_SOURCE[i]}"
        TIME=$(date -r ${MSG_TIMESTAMP[i]::-3})    # BSD
        echo ">> TIME: ${TIME}"
        echo ">>       ${MSG_BODY_NEW[i]}"
        if [[ ${MSG_GROUP[i]} != "null" ]] ; then
            for g in ${!GROUP_ID[@]}; do
                if [[ ${GROUP_ID[g]} == ${MSG_GROUP[i]} ]]; then
                    echo ">> In GROUP: ${GROUP_NAME[g]}"
                    gotcha=1
                fi
            done
            [[ $gotcha -ne 1 ]] && echo ">> In GROUP: Unknown"
        fi
        echo
    done

}
Output |more

exit
