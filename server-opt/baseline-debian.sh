#!/bin/bash
# BRIEF		This script is used to make a NEW instance set up to work.
# DATE		2020-10-08

set -eu

if [ $UID -ne 0 ]; then
    echo "Oops, you are NOT root. Quit."
    exit 1
fi

CWD=$(pwd)
mkdir -p ~/bin ~/tmp

# Add a Limited User Account
USER='linus'
useradd -m -G sudo,adm,users -s /bin/bash $USER || true
useradd -m -s /bin/bash -G users ipfs || true

chmod -R 700 /home/$USER/
mkdir -p -m 0700 /home/$USER/.ssh
cp ~/.ssh/authorized_keys /home/$USER/.ssh/authorized_keys
chown -R ${USER}. /home/$USER/

# Harden SSH Access
## SSH Daemon Options

SSHD_CFG="/etc/ssh/sshd_config"
echo -e "\n ## My settings ## 
\nPermitRootLogin no \nPasswordAuthentication no \nX11Forwarding no \nAllowAgentForwarding no
AllowTcpForwarding no
MaxAuthTries 2
LogLevel VERBOSE
" >> $SSHD_CFG

# Set sudoer
# Adjust sudo.
echo "$USER   ALL=(ALL) NOPASSWD: ALL" | EDITOR='tee -a' visudo

# Add backports and Update packages
echo -e "deb http://deb.debian.org/debian buster-backports main \ndeb http://security.debian.org/debian-security buster/updates main \n
deb-src http://security.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list
apt update && apt upgrade -y

# Remove compilers.
apt remove -y gcc locales-all linux-compiler-gcc-8-x86 g++ g++-8 libstdc++-8-dev linux-headers-4.19.0-6-common linux-kbuild-4.19

# De-execute gcc-8 for others:
chmod 750 /usr/bin/x86_64-linux-gnu-gcc-* || true

# Use some basic tools.
apt install -y jq python3-pip python3-requests locales tmux vim curl fail2ban nodejs npm nginx git wget w3m atop htop tmux gpg software-properties-common apt-listbugs apt-listchanges needrestart debsecan debsums libpam-tmpdir libgl1 libxi6 certbot python-certbot-nginx bind9-dnsutils

npm install npm -g

usermod -aG users www-data
rm /etc/nginx/sites-enabled/default || true

# Set locale
echo "LANG=en_US.UTF-8
export LANG
" > /etc/profile.d/lang.sh

# Set umask
echo "umask 027" >> $HOME/.profile

# Add third-party repo: Tor.
echo "
deb https://deb.torproject.org/torproject.org buster main
deb-src https://deb.torproject.org/torproject.org buster main
" > /etc/apt/sources.list.d/torproject.list

wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

apt update
apt install -y tor deb.torproject.org-keyring

# Add third-party repo: Docker.
curl -fsSL https://download.docker.com/linux/debian/gpg |apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt update
apt install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker $USER

# Pull my dotfiles
git clone https://github.com/mdrights/Myscripts.git /home/$USER/repo/Myscripts/ || true

chown -R ${USER}.  /home/$USER/repo

# Configure a Firewall
#$HOME/Myscripts/iptables-scripts/iptables.vps.sh start

# Install GitLab runner:
$HOME/Myscripts/server-opt/gitlab-runner-download.deb.sh

cat <<EOF | sudo tee /etc/apt/preferences.d/pin-gitlab-runner.pref
Explanation: Prefer GitLab provided packages over the Debian native ones
Package: gitlab-runner
Pin: origin packages.gitlab.com
Pin-Priority: 1001
EOF

apt update
apt install -y gitlab-runner || true

# gitlab-runner startup script:
echo '#!/bin/sh

/usr/lib/gitlab-runner/gitlab-runner "run" "--working-directory" "/home/gitlab-runner" "--config" "/etc/gitlab-runner/config.toml" "--service" "gitlab-runner" "--syslog" "--user" "gitlab-runner" &                     
' > /root/bin/start-gitlab-runner.sh

usermod -aG users gitlab-runner
usermod -aG users www-data
chown -R gitlab-runner:users /srv/
chmod -R 775 /srv/


## Install OSSEC:
# wget -q -O - https://www.atomicorp.com/RPM-GPG-KEY.atomicorp.txt |apt-key add -
# echo "deb https://updates.atomicorp.com/channels/atomic/debian buster main" >>  /etc/apt/sources.list.d/atomic.list
# apt update && apt install -y ossec-hids-server


# Install the monitoring and security stuff:
apt -t buster-backports install -y monit exim4-daemon-light apparmor-profiles apparmor-profiles-extra apparmor-utils auditd lynis

# Copy autid config.
cd /usr/share/doc/auditd/examples/rules/
cp 10-base-config.rules 30-stig.rules.gz 99-finalize.rules /etc/audit/rules.d/
cd  /etc/audit/rules.d/
gzip -d 30-stig.rules.gz
sh $HOME/Myscripts/auditd-conf/31-privileges.sh 
augenrules --load || true
cd $CWD

# TODO - needs human intervention to verify that all configs fit to the env.
cp /usr/share/apparmor/extra-profiles/* /etc/apparmor.d/
cp $HOME/Myscripts/apparmor-conf/* /etc/apparmor.d/
cd /etc/apparmor.d/
for file in *.dovecot*; do touch local/$file; done
cd -

aa-status || true


## Harden the kernel.
echo "        #### Set by root at $(date) ####
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.tcp_syncookies=1
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
kernel.core_uses_pid = 1
kernel.kptr_restrict = 2
kernel.sysrq = 0
net.ipv4.conf.all.forwarding = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.log_martians = 1
net.ipv6.conf.default.accept_redirects = 0
kernel.yama.ptrace_scope = 3
" > /etc/sysctl.d/90-hardening.conf

/sbin/sysctl --system


# Remove Unused Network-Facing Services
systemctl stop exim4
systemctl disable exim4

systemctl stop docker
systemctl disable docker

systemctl stop gitlab-runner.service
systemctl disable gitlab-runner.service

systemctl stop nginx
systemctl disable nginx

systemctl stop tor
systemctl disable tor

systemctl stop containerd
systemctl disable containerd


# Add hostname #TODO:
echo
read -p ">> Please let me know your hostname: " YOURHOST
echo "127.0.0.1       $YOURHOST" >> /etc/hosts

# Set locales
dpkg-reconfigure locales

echo
echo "  Restart SSH when you setup a user a/c + import your SSH key + clean your sshd_config: "  
echo  ">> systemctl restart sshd"
# systemctl restart sshd    #TODO  

exit
