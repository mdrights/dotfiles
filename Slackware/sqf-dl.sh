#!/bin/sh

# FILE  sqf-dl.sh  Download the packages in the sqf file. 
# AUTHOR mdrights
# DATE   2021-04-22

# $1=    # The sqf file you want to process
SQF=$1

PROXY=${PROXY:-proxychains4}

# Where Slackbuilds repo is.
REPO='/home/user/slackware-repo/slackbuilds'
SQFDIR='/home/user/slackware-repo/sbopkg/queues'
OUTPUTDIR='/home/user/slackware-repo/sbopkg/src/'

PKGLIST="$(cat ${SQFDIR}/${SQF} |grep -v '^#\|^$')"


for PKG in ${PKGLIST}; do
    echo -e "\n>> Downloading $PKG ..."
    PKGDIR=$(find $REPO -type d -maxdepth 2 -iname "${PKG}" | head -1)
    INFOFILE="${PKGDIR}/${PKG}.info"
    source $INFOFILE

    if [ -z "$DOWNLOAD_x86_64" ] || [ "$DOWNLOAD_x86_64" = "UNSUPPORTED" ]; then
        echo ">> from ${DOWNLOAD}"
        ${PROXY} wget -c ${DOWNLOAD} -P ${OUTPUTDIR}
        [ "$?" -ne 0 ] && echo ">> Oops, Download Failed."
    else
        echo ">> from ${DOWNLOAD_x86_64}"
        ${PROXY} wget -c ${DOWNLOAD_x86_64} -P ${OUTPUTDIR}
        [ "$?" -ne 0 ] && echo ">> Oops, Download Failed."
    fi
done

echo -e "\n>> Done!"
