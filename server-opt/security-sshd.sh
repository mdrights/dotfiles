#!/bin/bash
# Written at Mar 24, 2016, at Buji.
# Modified at Mar 29, 2016.
# Partly copied from https://github.com/citypw/DNFWAH/blob/master/4/d4_0x02_DNFWAH_gnu-linux_security_baseline_hardening.txt


echo "----- This is My VPS initialising script!-----"
echo "This VPS is based on: `uname -a`. Good luck!"

if [ $UID != 0 ];then
	echo "You should be root, dude."
	exit
fi

#0.0 Back up first!"
echo "0.0 Back up first!"

cp /etc/ssh/sshd_config /root/sshd_config
cp /etc/ssh/ssh_config /root/ssh_config

# 0.1 Install some software.
echo "0.1 Install some software."
apt-get update
apt-get install openvpn wget curl git-core iftop htop python python-pip mutt w3m pandoc iconv

echo "Install Shadowsocks."
pip install shadowsocks


# Checking security upgrade.
echo "1 Checking security upgrade."
apt-get upgrade -s 

echo "Do you want to upgrade now? If yes, press y:"
read u
if [ "$u" = "y" ];then
	apt-get upgrade -y
fi


#2 ssh
echo "2 openSSH setting."
echo "Do the SSH setting? (y or n)"
read c
if [ "$c" == "y" ];then

echo "HashKnownHosts yes
Protocol 2
X11Forwarding no
IgnoreRhosts yes
PermitEmptyPasswords no
MaxAuthTries 3
" >> /etc/ssh/sshd_config

	echo "Have you upload your ssh key already? -If yes, press y."
	read a
	if [ "$a" == "y" ];then
	echo "
	PubkeyAuthentication yes
	PasswordAuthentication no
	" >> /etc/ssh/sshd_config
	else
	echo "Still using password Authentication."
	fi

	echo "Have you create a normal user for yourself yet (in order to forbid root login)? -If yes, press y."
	read b
	if [ "$b" == "y" ];then
	echo "Forbiding root login..."
	echo "PermitRootLogin no" >> /etc/ssh/sshd_config
	else
	echo "Still Permitting root login. Do Change later."
	fi
fi



#echo "Check ACL status. (setfacl -m u:user:r file)"
#getfacl

#---------------------------------------------------------
#3. File Audit. -- moved to another script.

# 4 Prevent *UNSET* bash history
echo "4 Prevent *UNSET* bash history."

echo "
export HISTSIZE=1500
readonly HISTFILE
readonly HISTFILESIZE
readonly HISTSIZE
" >> /etc/profile

#Set .bash_history as attr +a
echo "Set .bash_history as attr +a"
find / -maxdepth 3|grep -i bash_history|while read line; do chattr +a "$line"; done

#5 sudoers

#6 Kernel Baseline -- forked from LinuxMint hardening at Hardenedlinux.org.
# Moved to another script."

#7 Hardening with Apparmor/Grsecurity

#8 SSL/TLS baseline

#echo "9. Browser (Firefox) privacy settings...please go there."
# Any other...

#10 Checking startup apps.
echo "Checking startup programs."

echo "Showing the listening ports:"
ss -tulp

#echo "Want to exit and cope with that? (y or n)"
#read b
#if [ "$b" == "y" ];then
#	exit
#fi

echo "Done."
echo 
exit 0

