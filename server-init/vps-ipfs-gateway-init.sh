#!/bin/bash

#set -eux

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

apt update && apt upgrade -y && apt install -y git curl ufw wget nginx atop
systemctl stop apache2 exim4 xinetd || true
systemctl disable apache2 exim4 xinetd || true

read -p ">> Continue? [Enter]" YES

#echo 
#echo ">> Open firewall holes:"
#ufw allow 22
#ufw allow 80
#ufw allow 4001
#ufw status verbose
#read -p ">> Continue? [Enter]" YES
#ufw enable


echo 
echo ">> Install IPFS (Kubo)"

IPFS_VERSION='0.22.0'
cd /opt/
wget -c https://dist.ipfs.tech/kubo/v${IPFS_VERSION}/kubo_v${IPFS_VERSION}_linux-amd64.tar.gz
tar xvf *.tar.gz

useradd -g users -m ipfs || true
chsh -s /bin/bash ipfs

echo
sudo -u ipfs /opt/kubo/ipfs init
chown -R ipfs. /opt/kubo/
cd ~

echo
echo ">>> Configure IPFS gateway to a custom domain (you can set it later as well):"
#sed '/PublicGateways/ { n; s/".*{/"TODO.com": {/g }' ~/.ipfs/config | grep -C2 PublicGateways
sed 's#"PublicGateways": null#"PublicGateways": { "TODO.domain": { "UseSubdomains": true, "Paths": ["/ipfs", "/ipns"] } }#g' /home/ipfs/.ipfs/config | grep -C2 PublicGateways

read -p ">> Is that okay? [Enter]" YES
#sed -i '/PublicGateways/ { n; s/".*{/"TODO.com": {/g }' ~/.ipfs/config
sed -i 's#"PublicGateways": null#"PublicGateways": { "TODO.domain": { "UseSubdomains": true, "Paths": ["/ipfs", "/ipns"] } }#g' /home/ipfs/.ipfs/config

echo
echo "... Copy ipfs.service and restart IPFS"
cp ~/ipfs.service /etc/systemd/system/

systemctl daemon-reload
systemctl start ipfs
systemctl enable ipfs
systemctl status ipfs


echo
echo ">> Configure NGINX proxy"
cp ~/nginx-ipfs-gw.conf /etc/nginx/sites-available/ipfs-gw
ln -s /etc/nginx/sites-available/ipfs-gw /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
ls -tl /etc/nginx/sites-enabled

nginx -t || exit 1
systemctl restart nginx
systemctl status nginx


echo
echo ">> Install Gitlab-runner"
cd ~
curl -L -o gitlab-runner-script.deb.sh  "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh"

bash gitlab-runner-script.deb.sh
echo
apt install -y gitlab-runner
echo
usermod -g users gitlab-runner
echo
service gitlab-runner status
echo

read -p ">> Do you want to connigure and register the runner? [Y/n]" YES
if [[ ${YES} != 'n' ]]; then
    gitlab-runner register
    echo "... You need to edit /etc/gitlab-runner/config.toml"
    #chown ipfs:gitlab-runner /home/ipfs/.ipfs/
    chmod 770 /home/ipfs/.ipfs
    echo 'gitlab-runner ALL=NOPASSWD:/usr/sbin/service' > /etc/sudoers.d/gitlab-runner
fi

echo
echo ">> Set cronjob for pinning IPFS"
cp ~/ipfs-pin.sh /home/ipfs/
chmod +x /home/ipfs/ipfs-pin.sh
chown ipfs. /home/ipfs/ipfs-pin.sh
echo '0 */2 * * * ipfs /home/ipfs/ipfs-pin.sh > /tmp/ipfs-pin.log' > /etc/cron.d/ipfs

echo
echo "====== Done! ======"
exit

