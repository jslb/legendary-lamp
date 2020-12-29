#!/bin/bash

#https://musicbrainz.org/doc/MusicBrainz_API/Search

mb_endpoint='http://musicbrainz.org/ws/2/recording/?query=artist:'
#artist='ac\%2Fdc'
artist='lorde'
#artist='taylor%swift'
limit='&limit=100'
declare -i offset_val=0
offset="&offset=${offset_val}"
url=${mb_endpoint}${artist}${limit}${offset}

curl GET $url -H "Accept: application/json" > $artist.data-$offset_val

declare -i count=$(cat $artist.data-$offset_val | jq '.count')

cat $artist.data-$offset_val | jq  '.recordings[].title' > $artist.songlist

if [[ $count > 100 ]];
then
	while [[ $count -gt $offset_val ]];
	do
		offset_val=$offset_val+100
		offset="&offset=${offset_val}"
		url=${mb_endpoint}${artist}${limit}${offset}
		curl GET $url -H "Accept: application/json" > $artist.data-$offset_val
		cat $artist.data-$offset_val | jq  '.recordings[].title' >> $artist.songlist


		
	done
	echo finsihed
fi
