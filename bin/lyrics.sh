#!/bin/bash

echo "Enter Your Artist:"
read artistName
artistNameSpaced=$artistName
echo "Chosen artist: $artistName"
artistName=$(echo ${artistName// /%20})

mb_endpoint='http://musicbrainz.org/ws/2/recording/?query=artist:'
artist=$(echo ${artistName// /%20})
limit='&limit=100'
declare -i offset_val=0
offset="&offset=${offset_val}"
url=${mb_endpoint}\"${artist}\"${limit}${offset}

curl -s $url -H "Accept: application/json" > ../tmp/$artist.data-$offset_val

declare -i count=$(cat ../tmp/$artist.data-$offset_val | jq '.count')

cat ../tmp/$artist.data-$offset_val | jq -c ".recordings[] | select(.\"artist-credit\"[].name==\"$artistNameSpaced\") | {title: .title, artist: .\"artist-credit\"[].name}" > ../tmp/$artist.songlist

if [[ $count > 100 ]];
then
    while [[ $count -gt $offset_val ]];
    do
        offset_val=$offset_val+100
        offset="&offset=${offset_val}"
        url=${mb_endpoint}\"${artist}\"${limit}${offset}
        curl -s $url -H "Accept: application/json" > ../tmp/$artist.data-$offset_val
        cat ../tmp/$artist.data-$offset_val | jq -c -c ".recordings[] | select(.\"artist-credit\"[].name==\"$artistNameSpaced\") | {title: .title, artist: .\"artist-credit\"[].name}" >> ../tmp/$artist.songlist
        #cat ../tmp/$artist.data-$offset_val | jq -c '.recordings[] | select(."artist-credit"[].name=="Easy Life") | {title: .title, artist: ."artist-credit"[].name}' >> ../tmp/$artist.songlist
    done
    echo finsihed
    rm ../tmp/$artist.data-*
fi

declare -i totalWordCount=0
declare -i songCount=0
while IFS= read -r line
do
    #echo "$line"
    #songName=$(echo cut -d ',' -f1 $line)
    songName=$(echo $line | awk -F':' '{ print $2 }' | cut -d ',' -f1)
	songName=$(echo ${songName//\"/})
    #echo $songName

	songNameSpaced=$songName
	songName=$(echo ${songName// /%20})

	lyric_endpoint="https://private-anon-b06597b77b-lyricsovh.apiary-proxy.com/v1"
	data="${artistName}/${songName}"
	lyric_url="${lyric_endpoint}/${data}"

	lyrics=$(curl -s $lyric_url)
	lyricsClean=$(echo $lyrics | jq '.lyrics')
	declare -i wordCount=$(echo $lyricsClean | wc -w)

	if [[ $wordCount != 1 ]];
	then
		totalWordCount=$((totalWordCount+wordCount))
		songCount=$(( songCount += 1 ))
	fi
	echo $lyrics | jq ". | {song: \"$songNameSpaced\", lyrics: .lyrics, wordCount: \"$wordCount\"}" >> ../tmp/$artist.lyrics


	#echo $totalWordCount
done < ../tmp/$artist.songlist

declare -i averageWord=$(( $totalWordCount / $songCount ))
echo totalWordCount: $totalWordCount sonCount: $songCount
echo average: $averageWord


rm ../tmp/$artist.*
