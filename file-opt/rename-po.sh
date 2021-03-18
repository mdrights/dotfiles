#!/bin/bash

FileList=$(find . -type f -regex ".*\.zh\..*")

for file in $FileList
do
	echo $file
	prefix=${file%%.z*}
	echo $prefix
	newfile="$prefix.zh_CN.po"
	echo $newfile
	cp $file $newfile

done

exit

