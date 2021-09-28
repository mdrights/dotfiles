#!/usr/bin/env bash
# Read and parse the json format messages pulled from signal-cli.
# This needs jq tool and Bash; Some commands need the BSD(POSIX) version.
# DATE  2021-09-28

set -eu

JQ=$(which jq)
MSG_FILE="/tmp/signal.msg"

Parse_Group() {
    declare -A GROUP_MAP
    GROUP_FILE="$HOME/signal.groups"
    GROUP_ID=($(cat ${GROUP_FILE} | jq '.[].id'))
    GROUP_NAME="$(cat ${GROUP_FILE} | jq '.[].name')"

    for G in ${!GROUP_ID[@]}; do
        GROUP_MAP[${GROUP_ID[$G]}]=${GROUP_NAME[$G]}
    done

    #echo ${GROUP_MAP[@]}
    #echo ${!GROUP_MAP[@]}
}
#Parse_Group


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
        echo ">> In GROUP: ${MSG_GROUP[i]}"
        echo
    done

}
Output

exit
