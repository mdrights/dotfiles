#!/bin/bash

# BRIEF     slackware-update-tagfile.sh: update the tagfiles in the official repo to suit to my demands:
#           1. Deblobbing
#           2. Skip / comment out the software I do not want to install
#
# AUTHOR    mdrights
# DATE      May 02 2021


#REPO_DIR='/mnt/hd/user/slackware-repo/slackware64-current/slackware64'
REPO_DIR='/home/user/slackware-repo/slackware64-current/slackware64'
#TAG_DIR=(a/  ap/  d/  e/  f/  k/  l/  n/  t/  tcl/  x/  xap/  xfce/  y/)
#BLOB="/home/user/repo/libreslack/blob.list"
UNWANT='/home/user/repo/LiveSlak/tagfiles/skipped-pkgs.list'


echo "========== The pkg list for skipping ==========="
cat $UNWANT
echo "========== The pkg list for skipping ==========="
read -p "Do you want to proceed? (Y/n)" YES

[ "$YES" = "n" ] && exit 0


while read -r line; do 
    DIR=$(echo ${line} |cut -d" " -f1)
    PKG=$(echo ${line} |cut -d" " -f2)
	echo ">>> Processing $PKG in $DIR ..."

	if grep "^${PKG}:" ${REPO_DIR}/${DIR}/tagfile; then 
        echo "... Mark pkg <$PKG> as SKP."
        sed -i "s/${PKG}:.*/${PKG}:SKP/" ${REPO_DIR}/${DIR}/tagfile
    else
        echo "... pkg $PKG does not exist in the repo now."
	fi
done < <(cat ${UNWANT} | grep -v '^$\|^#')

echo ">>> Done!"
exit
