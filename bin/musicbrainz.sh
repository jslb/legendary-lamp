#!/bin/bash

#https://musicbrainz.org/doc/MusicBrainz_API/Search

mb_endpoint='http://musicbrainz.org/ws/2/recording/?query=artist:'
#artist='ac\%2Fdc'
#artist='lorde'
artist='taylor%20swift'
#artist='queen'
limit='&limit=100'
declare -i offset_val=0
offset="&offset=${offset_val}"
url=${mb_endpoint}\"${artist}\"${limit}${offset}
echo $url

curl GET $url -H "Accept: application/json" > ../tmp/$artist.data-$offset_val

declare -i count=$(cat ../tmp/$artist.data-$offset_val | jq '.count')

#cat ../tmp/$artist.data-$offset_val | jq  '.recordings[].title' > ../tmp/$artist.songlist
cat ../tmp/$artist.data-$offset_val | jq '.recordings[] | {title: .title, artist: ."artist-credit"[].name}' > ../tmp/$artist.songlist
#'.[] | {message: .commit.message, name: .commit.committer.name}'

if [[ $count > 100 ]];
then
	while [[ $count -gt $offset_val ]];
	do
		offset_val=$offset_val+100
		offset="&offset=${offset_val}"
		url=${mb_endpoint}\"${artist}\"${limit}${offset}
		curl GET $url -H "Accept: application/json" > ../tmp/$artist.data-$offset_val
		#cat ../tmp/$artist.data-$offset_val | jq  '.recordings[].title' >> ../tmp/$artist.songlist
		cat ../tmp/$artist.data-$offset_val | jq '.recordings[] | {title: .title, artist: ."artist-credit"[].name}' >> ../tmp/$artist.songlist
		
	done
	echo finsihed
fi
