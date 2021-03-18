#!/bin/bash
# 2016.08.13

Pattern="htm"
Dir="$PWD"
File=$(find $PWD -name \*.$Pattern)

for file in $File
do
	ofile="${file%$Pattern}md"
	pandoc -f html -t markdown_github $file -o $ofile 
	echo "Okay for $ofile"
done

echo 
exit 0

