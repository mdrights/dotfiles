#!/bin/bash
# Written on 15 June 2016.

# sudo tail -n 1000 /var/log/messages | grep -c "BLOCKED"

CurMonth=`date +%b`
CurDay=`date +%d`
zero=`echo ${CurDay:0:1}`


# Filter and number the Incoming but blocked requests within today.

if [ $zero == 0 ];then
        CurDay="${CurDay:1:1}"
        grep 'BLOCKED' /var/log/messages | grep -c "$CurMonth  $CurDay"
else
        grep 'BLOCKED' /var/log/messages | grep -c "$CurMonth $CurDay" 
fi
echo
exit

