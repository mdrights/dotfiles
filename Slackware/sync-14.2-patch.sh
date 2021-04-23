#!/bin/sh

rsync -avz --delete --exclude='source' rsync://hkg.mirror.rackspace.com/slackware/slackware64-14.2/patches/ ~/slackware-repo/patches/
