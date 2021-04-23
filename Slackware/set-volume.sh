#!/bin/bash

OPT=$1

case $OPT in
	up)
	amixer sset Master,0 5%+
	;;
	down)
	amixer sset Master,0 5%-
	;;
	*)
	echo "Oops, invalid argument. Quit."
	exit 1
	;;
esac

exit
