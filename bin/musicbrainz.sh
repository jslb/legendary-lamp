#!/bin/bash

#https://musicbrainz.org/doc/MusicBrainz_API/Search

mb_endpoint='http://musicbrainz.org/ws/2/recording/?query=artist:'
#artist='ac\%2Fdc'
#artist='lorde'
artistName='Easy Life'
#artistName='taylor swift' #does not work if wrong case
artist=$(echo ${artistName// /%20})
limit='&limit=100'
declare -i offset_val=0
offset="&offset=${offset_val}"
url=${mb_endpoint}\"${artist}\"${limit}${offset}
echo $url

curl GET $url -H "Accept: application/json" > ../tmp/$artist.data-$offset_val

declare -i count=$(cat ../tmp/$artist.data-$offset_val | jq '.count')

cat ../tmp/$artist.data-$offset_val | jq -c ".recordings[] | select(.\"artist-credit\"[].name==\"$artistName\") | {title: .title, artist: .\"artist-credit\"[].name}" > ../tmp/$artist.songlist
#cat ../tmp/$artist.data-$offset_val | jq -c '.recordings[] | select(."artist-credit"[].name=="Easy Life") | {title: .title, artist: ."artist-credit"[].name}' > ../tmp/$artist.songlist


if [[ $count > 100 ]];
then
	while [[ $count -gt $offset_val ]];
	do
		offset_val=$offset_val+100
		offset="&offset=${offset_val}"
		url=${mb_endpoint}\"${artist}\"${limit}${offset}
		curl GET $url -H "Accept: application/json" > ../tmp/$artist.data-$offset_val
        cat ../tmp/$artist.data-$offset_val | jq -c -c ".recordings[] | select(.\"artist-credit\"[].name==\"$artistName\") | {title: .title, artist: .\"artist-credit\"[].name}" >> ../tmp/$artist.songlist
		#cat ../tmp/$artist.data-$offset_val | jq -c '.recordings[] | select(."artist-credit"[].name=="Easy Life") | {title: .title, artist: ."artist-credit"[].name}' >> ../tmp/$artist.songlist
	done
	echo finsihed
	rm ../tmp/$artist.data-*
fi

