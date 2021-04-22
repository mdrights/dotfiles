#!/bin/bash

PKG=($(find ./a -type f ! -regex ".*kernel-.*txz" -name "*.txz"))

for p in ${PKG[@]}
do
	echo $p
done


