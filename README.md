# legendary-lamp

Iteract with APIs tech test for Aire Logic


Brief: Produce a program which, when given the name of an artist, will produce the average
number of words in their songs.

This is the dev banch

This is a bash shell script that uses the lyrics.ovh and musicbrainz APIs to calculate the approximate number of words per song on average by an arists inputted by the user.

Requirements:
* jq installed
https://stedolan.github.io/jq/download/?fbclid=IwAR1nMeE7xT3O0RiahxWuhTao7ixzwRCD-mpT0zkqUzcT-ixZU0M_xF49WT8

How to Run:
* Clone the repository
* Ensure the script is executable (chmond -x+u main.sh)
* run from repo_path/bin/
	`./main.sh`

The user is prompted to input a musican/band name/musical artist
The script then uses the input and the musicbrainz API to retrive all recordings associated with the target arist
After some data cleasning, the lyrics.ovh API is used to get the lyrics for each song by the artist
The word counts are recorded and the average word count per song is calculated and displayed for the user.

From here there are 3 actions:
1 - - list all songs found to be by the target arists (inlcuding those without lyrics available)
2 - - display lyrics of a chosen song (see below) 
3 / exit - - closes the program

To display the lyrics of a particular song, choose option 2 at the more info prompt
It will list all the songs by the target artists whose lyrics have been sucessfully retrieved,
Enter the number next to the target song
After the lyrics have been printed there is a Y/N option to display the word count of the chosen song.
The end of this returns teh user to the more options prompt.

