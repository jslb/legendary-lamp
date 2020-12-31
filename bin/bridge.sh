#!/bin/bash

artistName='Easy Life'
artist=$(echo ${artistName// /%20})

while IFS= read -r line
do
 	#echo "$line"
	#songName=$(echo cut -d ',' -f1 $line)
	songName=$(echo $line | awk -F':' '{ print $2 }' | cut -d ',' -f1)
	echo $songName

done < ../tmp/$artist.songlist 
