#!/bin/bash

#https://musicbrainz.org/doc/MusicBrainz_API/Search

url='http://musicbrainz.org/ws/2/recording/?query=artist:ac\%2Fdc'
curl GET $url 
