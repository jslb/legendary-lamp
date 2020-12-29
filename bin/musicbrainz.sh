#!/bin/bash

#https://musicbrainz.org/doc/MusicBrainz_API/Search

mb_endpoint='http://musicbrainz.org/ws/2/recording/?query=artist:'
#artist='ac\%2Fdc'
artist='lorde'
url=${mb_endpoint}${artist}
curl GET $url -H "Accept: application/json" | jq  '.recordings[].title' > ../tmp/$artist.song 
