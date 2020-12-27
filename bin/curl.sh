#!/bin/bash

echo "Enter Your Artist:"
read artistName
echo "Enter Your Song:"
read songName
echo "Chosen artist and song: $songName by $artistName"

fileName=$(echo ${songName// /_})

#artistName="Taylor Swift"
artistName=$(echo ${artistName// /%20})
#songName="Red"
songName=$(echo ${songName// /%20})

lyric_endpoint="https://private-anon-b06597b77b-lyricsovh.apiary-proxy.com/v1"
#data="Taylor%20Swift/Red"
data="${artistName}/${songName}"
url="${lyric_endpoint}/${data}"
echo $url
#curl GET https://private-anon-b06597b77b-lyricsovh.apiary-proxy.com/v1/Taylor%20Swift/Red
curl GET $url > ../tmp/$fileName
