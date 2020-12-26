#!/bin/bash
set -v
set -x
PATH=~/legendary-lamp

echo "Enter Your Artist:"
read artistName
echo "Enter Your Song:"
read songName
echo "Chosen artist and song: $songName by $artistName"

fileName=$(echo ${songName// /_})
fileName="${songName}.json"

lyric_endpoint="https://private-anon-b06597b77b-lyricsovh.apiary-proxy.com/v1"
artistName=$(echo ${artistName// /%20})
songName=$(echo ${songName// /%20})

data="/${artistName}/${songName}"
url=${lyric_endpoint}${data}
#echo $url
#echo $PATH/tmp/$fileName
#echo curl -X GET $url #> ../tmp/$fileName #$PATH/tmp/$fileName
curl GET "https://private-anon-b06597b77b-lyricsovh.apiary-proxy.com/v1/lorde/royals"

#curl -X GET https://private-anon-b06597b77b-lyricsovh.apiary-proxy.com/v1/Taylor%20Swift/Red

