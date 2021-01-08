# legendary-lamp

Iteract with APIs tech test for Aire Logic


Brief: Produce a program which, when given the name of an artist, will produce the average
number of words in their songs.

This is a bash shell script that uses the lyrics.ovh and musicbrainz APIs to calculate the approximate number of words per song on average by an arists inputted by the user.

Requirements:
* jq installed [download here](https://stedolan.github.io/jq/download/?fbclid=IwAR1nMeE7xT3O0RiahxWuhTao7ixzwRCD-mpT0zkqUzcT-ixZU0M_xF49WT8)

How to Run:
* Clone the repository
* Navigate to REPO_PATH/bin/
* Ensure main.sh is executable
* Run with the following command:
	`./main.sh`

The user is prompted to input a musican/band name/musical artist

The script then uses the input and the [musicbrainz API](https://musicbrainz.org/doc/MusicBrainz_API) to retrive all recordings associated with the target arist
After some data cleasning, the [lyrics.ovh API](https://lyricsovh.docs.apiary.io/#reference) is used to get the lyrics for each song by the artist

The word counts are recorded and the average word count per song is calculated and displayed for the user.

From here there are 4 available actions:
- 1 - - list all songs found to be by the target arists (inlcuding those without lyrics available)
- 2 - - display lyrics of a chosen song (see below) 
- 3 - - display the stats for the artist again 
- 4 / exit - - closes the program

To display the lyrics of a particular song, choose option 2 at the more info prompt
It will list all the songs by the target artist whose lyrics have been sucessfully retrieved,
Enter the number next to the target song
After the lyrics have been printed there is a Y/N option to display the word count of the chosen song.
The end of this returns teh user to the more options prompt.

Some fast examples to get you started:
* Niko B (Super fast -returns 1 song)
* Easy Life (Takes a few mins -returns lyrics for 12 songs)
* Death Grips (Returns about 100 songs with lyrics)

