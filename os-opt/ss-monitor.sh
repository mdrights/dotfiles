#!/bin/bash
# Monitoring 1) who connects to my ssserver; 2)what ip/websites do they visit.
# Modified on the 2nd of Apr, 2016. I stop printing the 2), rather print the output flow numbers overall.
# Modified on the 4th of Apr, adding statistic feature of incoming ip addresses.

if [ $UID != 0 ];then
	echo "Sorry, you must be root!"
	exit 0
fi


Filein=/tmp/SS-in.txt
Fileout=/tmp/SS-out.txt
Result=/home/linus/SS-Result.txt
Tmp=/tmp/incoming-ip.txt

CurMonth=`date +%b`
CurDay=`date +%d`
zero=`echo ${CurDay:0:1}`

echo "Your host's listening ports." > $Result
ss -tulp | grep -o "users.*" >> $Result
echo >> $Result

# Filter and writing the Incoming IPs within today.

if [ $zero == 0 ];then
        CurDay="${CurDay:1:1}"
	grep 'SS-in' /var/log/messages | grep "$CurMonth  $CurDay" > $Filein
else
	grep 'SS-in' /var/log/messages | grep "$CurMonth $CurDay" > $Filein
fi

echo "`date`, `hostname`." >> $Result
echo "Shadowsocks Incoming IPs:" >> $Result
echo >> $Result

/usr/bin/awk '{print $1$2; print $11}' $Filein > $Tmp

# Changed as removing duplicate ip addresses; and display the connections of each ip.
echo "And the connections of each ip addresses." >> $Result

n=`egrep -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" $Tmp | sort -u`
p=1

for y in $n
do
	q=`grep -c "$y" $Tmp`
	echo "$p. $y:  $q connections." >> $Result
	let p=p+1
	done

t=`egrep -c "SRC=.*" $Tmp`

echo >> $Result
echo "    Total $t connections." >> $Result
echo >> $Result
echo "---------------------------------------" >> $Result

# Filter and writing the Destination IPs within today.
# Not doing it now.

#grep 'SS-out' /var/log/messages | grep "$CurMonth $CurDay" > $Fileout

#echo "Shadowsocks Outgoing IPs:" >> $Result
#echo >> $Result

#/usr/bin/awk '{print $1$2; print $10}' $Fileout >> $Result


echo >> $Result
echo "The total OUTPUT packets and bytes." >> $Result

/sbin/iptables -vnL OUTPUT | sed -n '1p' >> $Result

echo >> $Result

echo "Done.
Sending email..."

cat $Result | mutt -s "SS usage at `date`, `hostname`" linusyeung@live.com

echo
exit 0
