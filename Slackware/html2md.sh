#!/bin/bash


DIR=/home/user/src/HTML
OUTDIR=/home/user/src/MD

cd $DIR

HTML=$(find . -type f -iname "*.html")

IFS=$'\n'

for file in $HTML; do
        outfile="${file%.*}.md"
        echo "> Converting: $outfile"
        #echo "pandoc -f html -t markdown_github $file -o \"$OUTDIR/$outfile\""
        #pandoc -f html -t markdown_github $file -o "$OUTDIR/$outfile"
		/home/user/bin/html2text.py -d $file > "$OUTDIR/$outfile"

		sleep 0.5
done

exit

