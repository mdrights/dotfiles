#!/bin/sh

set -eux

#[[ "$UID" -ne 0 ]] && exit 1


if [ ! -f /etc/ssh/sshd_config.orig ]; then
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
fi
cp ./sshd_config /etc/ssh/sshd_config

mkdir -p ~/.ssh && chmod 700 ~/.ssh/

echo '
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC790h49IJ51JOJT0Juuj8agj1/9QD80RxDH6z/OU6Y5tZE2maYo57P0TV98Mf+gxH8JDDJtLROVNbambMTh5iO3+R3bwIYkachodIJwhm5ziehXS2uND6NUi3L4GLye5Q4qfYJbiptiHPdhUDb4BhEMVZs3BvildRZ4yfJ70vxBHkn5fp420+Yghbd4x/j/ACA3v9QTCvRwPAikNIOm9Ao+qc/VgBg9wS/ExbMwcUpmlaoRYjbFbxonuzWeecpjmMph1WswrtlA3SBdYwuJ+kFPqdFCQUc0s0jRtWvzXt2pgEiobnKXOlwnnOjllZhMYcVNv8N7wLaS1Jo5sMyudeDOSNFNn4inFss69teJZdhdmejzl7ipuFOUZe865d7TeFZaBCSUhLvMG/FrHitqJoSfzUyRNmwPDFHjgqBit6HJ8hSqBxzR1oJfrk0CQMW3GcBG+HXntvipNkzFBzfMRIjQlIWr5HldWVjaLWWY2ErGLdtOg2LriRW11wQxpaxOhosJvi45JMC5OYyirxyT2/T8y2jC/3Trc7gbXMgicTT14LeYvXCBlzsvnx1fKnb/FG0Uaet6nBeUNWVwOrvbkbqlqlV5QOgz0R+ELjtK+HMsQ8jjVc8BpouZRezXgYmaFz/QFlgORsVokLhyh+8V0inhGDvqjQFPYrOvnkOGYzHwQ==' >> .ssh/authorized_keys

chmod 600 ~/.ssh/authorized_keys
cat ~/.ssh/authorized_keys

read -p ">> Continue? [Enter]" YES


service sshd restart && service sshd status

read -p ">> Continue? [Enter]" YES

apt update && apt upgrade -y && apt install -y git curl ufw wget
systemctl stop apache2 exim4 xinetd || true
systemctl disable apache2 exim4 xinetd || true

read -p ">> Continue? [Enter]" YES

bash -c "$(wget -qO- https://raw.githubusercontent.com/Jigsaw-Code/outline-server/master/src/server_manager/install_scripts/install_server.sh)"

echo 
echo ">> Open firewall holes:
# ufw allow 22
# ufw allow xxxxx
# ufw status verbose
# ufw enable
"

echo "Done!"
exit
