#!/bin/bash

Dir="$PWD"
Pattern="txt"
File=$(find "$Dir" -name \*.txt)
Out="md"

for file in $File
do
	Inname=${file%$Pattern};
	Outname="$Inname$Out";
	echo "$file --> $Outname";
	mv "$file" "$Outname";	
done
echo "Done."

echo
exit 0

