#!/bin/bash

#Get artist name from user
printf "Ready to get some lyrics? The search is case sesnitive so be careful to capitalise names correctly!\nEnter Your Artists name:\n"
read artistName
artistNameSpaced=$artistName
echo "Chosen artist: $artistName"

#Create musicbrainz url for intial curl
artistName=$(echo ${artistName// /%20})
artist=$(echo ${artistName// /%20})
mb_endpoint='http://musicbrainz.org/ws/2/recording/?query=artist:'
#Musicbrainz limit the number of responses
#Set up vars for offset and limit
limit='&limit=100'
declare -i offset_val=0
offset="&offset=${offset_val}"
url=${mb_endpoint}\"${artist}\"${limit}${offset}

#Perform first curl and store data
curl -s $url -H "Accept: application/json" > ../tmp/$artist.data-$offset_val

#Extract songs with artist-credit[].name matching users artist and store
cat ../tmp/$artist.data-$offset_val | jq -c ".recordings[] | select(.\"artist-credit\"[].name==\"$artistNameSpaced\") | {title: .title, artist: .\"artist-credit\"[].name}" > ../tmp/$artist.songlist
echo Getting songs by $artistNameSpaced ...
#Get total recordings count for artist
declare -i count=$(cat ../tmp/$artist.data-$offset_val | jq '.count')

if [[ $count == 0 ]];
then
	printf "Whoops! Looks like something went wrong. The search returned no songs :(\nIt's likely the capitalisation wasn't quite right, have a look at these examples and run the program again when you're ready\n Incorrect: tina turner\tCorrect: Tina Turner\n Incorrect: The beatles\tCorrect: The Beatles\n Incorrect: QUEEN\tCorrect: Queen\n\nIf this is the second time you're seeing this message for the same artist it might be that they have 0 songs in the database, if you think this is unlikley have another go at getting the capitals right for the search :)"	
	rm ../tmp/$artist.*
	exit
fi

#If number of recordings (count) exceeds limit (100), produce and perform remaining curl requests
if [[ $count > 100 ]];
then
    while [[ $count -gt $offset_val ]];
    do
		#Prepare the new url
        offset_val=$offset_val+100
        offset="&offset=${offset_val}"
        url=${mb_endpoint}\"${artist}\"${limit}${offset}
		#Perform the curl
        curl -s $url -H "Accept: application/json" > ../tmp/$artist.data-$offset_val
		#Extract songs with artist-credit[].name matching users artist and store
        cat ../tmp/$artist.data-$offset_val | jq -c -c ".recordings[] | select(.\"artist-credit\"[].name==\"$artistNameSpaced\") | {title: .title, artist: .\"artist-credit\"[].name}" >> ../tmp/$artist.songlist

		echo "... $artistNameSpaced is mentioned in over $offset_val database entires! Looks like someones been busy!"
		#The Musicbrainz api has rate limiting, max requests are capped at 1 request per second
		#This ensures requests are kept below the limit
		sleep 1
    done
printf "Just in case $offset_val songs seemed like a lot, don't worry, duplicates from the list have been removed and $artistNameSpaced has been verifed as the artist for every song on the list!\n\tNote: Remixes and re-releases with a different song title will still be included in the lyric search ..."
fi

#Removes other credited (featured) artists and duplicate songs (exact matches) from the data
sed "/$artistNameSpaced/!d" ../tmp/$artist.songlist > ../tmp/$artist.songlist.tmp
awk '!seen[$0]++' ../tmp/$artist.songlist.tmp > ../tmp/$artist.songlist
rm ../tmp/$artist.songlist.tmp

declare -i totalWordCount=0
declare -i songCount=0

lineCount=$(wc -l < ../tmp/$artist.songlist)

printf "\n... Getting lyrics for $lineCount songs now..."

#Get lyrics for each song from data
while IFS= read -r line
do
	#Get and format song name for API use
    songName=$(echo $line | awk -F':' '{ print $2 }' | cut -d ',' -f1)
	songName=$(echo ${songName//\"/})
	songNameSpaced=$songName
	songName=$(echo ${songName// /%20})
	#Produce lyric API
	lyric_endpoint="https://private-anon-b06597b77b-lyricsovh.apiary-proxy.com/v1"
	data="${artistName}/${songName}"
	lyric_url="${lyric_endpoint}/${data}"

	#Perform curl for lyrics
	lyrics=$(curl -s $lyric_url)
	#Clean lyrics
	lyricsClean=$(echo $lyrics | jq '.lyrics')
	lyricsClean=$(echo "${lyricsClean//'\n'/$'\n'}")
    lyricsClean=$(echo "${lyricsClean//'\r'/$'\n'}")
    lyricsClean=$(echo "${lyricsClean//'\'/$'\n'}")
	lyricsClean=$(echo ${lyricsClean//\"/})

	#Get word count
	declare -i wordCount=$(echo $lyricsClean | wc -w)
	#If lyrics are returned add to count for average calculations
	if [[ $wordCount != 0 ]];
	then
		totalWordCount=$((totalWordCount+wordCount))
		songCount=$(( songCount += 1 ))
	fi

	#Store all relevant data
	echo $lyrics | jq ". | {song: \"$songNameSpaced\", lyrics: \"$lyricsClean\", wordCount: \"$wordCount\"}" >> ../tmp/$artist.lyrics

done < ../tmp/$artist.songlist

#Calculate average words per song and print user message with further options
declare -i averageWord=$(( $totalWordCount / $songCount ))
printf "\n**********************\n$songCount songs returned lyrics, for a total word count of $totalWordCount giving an average of $averageWord words per song by artist $artistNameSpaced \n**********************\nMore options: to print the full list of songs enter 1, to see the lyrics for a song press 2, to see the stats again press 3 and to exit type 4 or 'exit'\n"
read options

#Additional options while loop
while [[ $options == 1 || $options == 2 || $options == 3  ]];
do
	#Option 1: lists all songs by target artist
	if [[ $options == 1 ]];
	then
		printf "The full list of songs by $artistNameSpaced:\n********************************************\n"
		cat ../tmp/$artist.lyrics | jq 'if .lyrics then .song else empty end'
	#Option 2: list songs with lyrics available
	elif [[ $options == 2 ]];
	then
		#Get songs with lyrics
		cat ../tmp/$artist.lyrics | jq 'if .lyrics != "" then .song else empty end' > ../tmp/$artist.lyricedsongs
		#Print INT: song name for all songs with lyrics available
		echo Lyrics are available for the following songs:
		declare -i lineOptions=1
		while IFS= read -r line
		do
			echo "$lineOptions: $line"
			lineOptions=$((lineOptions+1))			
		done < ../tmp/$artist.lyricedsongs

		#User prompt for song selection
		echo Please enter the number matching the desired song:
		read userOption
		#Get song name from user input
		chosenSong=$(sed -n ""$userOption"p" ../tmp/$artist.lyricedsongs)
		chosenSong=$(echo ${chosenSong//\"/})
		#Print lyrics for target song
		printf "*****************\n$chosenSong by $artistNameSpaced\n*****************\n"
		cat ../tmp/$artist.lyrics | jq "if select(.song==\"$chosenSong\") then .lyrics else empty end"
		#Prompt for user to display word count for target song
		printf "*****************\nDisplay word count for $chosenSong? (Y/N)\n"
		read wordCountInput
		
		#If user input is Yes, print word count
		if [ $wordCountInput == "y" ] || [ $wordCountInput == "Y" ];
		then
			echo "*****************"
			cat ../tmp/$artist.lyrics | jq "if select(.song==\"$chosenSong\") then .wordCount else empty end"
			echo "*****************"
		fi
	#Option 3: see the stats again
	elif [[ $options == 3 ]];
    then
        printf "\n***************** $artistNameSpaced's stats *****************\n\tNumber of verified releases:\t\t$lineCount\n\tNumber of songs with lyrics available:\t$songCount\n\tAverage word count per song:\t\t$averageWord\n\tTotal Word Count:\t\t\t$totalWordCount\n\n"
	fi
	#Loop back to offer additional option again
	echo "More options: to print the full list of songs enter 1, to see the lyrics for a song press 2, to see the stats again press 3 and to exit type 4 or 'exit'"
	read options

done

rm ../tmp/$artist.*
exit

