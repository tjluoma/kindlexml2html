#!/bin/zsh
# "Translate" the Mac Kindle.app's XML file (book list) into an HTML page showing title, author, and publisher
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2013-12-17

NAME="$0:t:r"

	# this is where it is on my system, I assume it is standard
XML="$HOME/Library/Application Support/Kindle/Cache/KindleSyncMetadataCache.xml"

	# If you prefer another browser, put it here
BROWSER="Safari"

	# if you don't want to scp the resulting file somewhere when you finish, leave SERVER="" blank
SERVER=""

SERVER='dh'
	SERVER_FOLDER='share.luo.ma/kindle'
		URL="http://$SERVER_FOLDER/"

if [ ! -e "$XML" ]
then
		echo "$NAME: No file found at $XML"
		exit 1
fi

	# The Kindle.app doesn't save that XML file until it quits, so if it is still running, you might
	# not get all of your books if you have just updated the Kindle app.
ps cx -o pid,command | egrep -q ' Kindle$' && echo "$NAME: WARNING! Kindle.app is running. For best results you should quit the app after it has had a chance to sync with Amazon's servers, and then run this script. If you have purchased any books since the last time you ran the app, they may not appear in the output."

zmodload zsh/datetime

TIME=$(strftime "%d-%B-%Y at %H:%M" "$EPOCHSECONDS")

SECONDS=$(strftime "%s" "$EPOCHSECONDS")

	# temp file
HTML="/tmp/$NAME.$USER.$RANDOM.$SECONDS.html"

	# Make sure the file doesn't exist (there's really no way it could, I don't think)
rm -f "$HTML"

	# Get the currently logged in User's "Real Name"
REAL_NAME=$(finger -l | fgrep 'Name: ' | sed 's#.*Name: ##g')

	# Start the HTML file
cat <<EOINPUT > "$HTML"
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8"/>
	<title>$REAL_NAME’s List of Kindle Books</title>

	<style media="screen" type="text/css">

		a { text-decoration: none; color: midnightblue; background-color:white; }

		a:visited { color:black; background-color:white; text-decoration: underline; }

		a:hover { color: red; background-color:white; }

		p#footer { text-align: right; font-size: smaller; margin-right: 5em; }

		thead * { font-weight: bold; }

		table { width: 100%; max-width: 100%; border: solid black 1px; background-color: midnightblue; color:white; }

		td { border: midnightblue solid 1px; padding: 1em; background-color: white; color: black; }

	</style>

</head>
<body>

<table>
<thead>
	<tr>
		<td>Title (linked to AMZN)</td>
		<td>Author(s)</td>
		<td>Publisher(s)</td>
	</tr>
</thead>
EOINPUT

# I decided to see how many times I could invoke 'sed' in one command. So far my record is 5.
# The first line removes the leading and trailing data
# the second puts each book on its own line
# fgrep removes lines which seem to be just spacers
# the next one does a lot
#	removes a bunch of XML pairs we aren't going to use
# 	replaces some XML pairs with HTML
# 	Add <a href="http://www.amazon.com/exec/obidos/ASIN/ before the actual ASIN
# 	fix one book title which is listed in ALL CAPS for reasons I can't begin to fathom
# 	Sort book by their title (this is weak, since it doesn't know to skip words like "A" and "The" but oh well
# 	double space the results, which is pointless except that I find it easier to read

sed 's#.*\<add_update_list>##g ; s#\</add_update_list>.*##g' "$XML" |\
sed 's#\</meta_data>#\</meta_data>\
#g' |\
fgrep -v '<title>---------------</title>' |\
sed 's#\<is_multimedia_enabled\>.*\</is_multimedia_enabled\>##g; s#\<cde_contenttype\>.*\</cde_contenttype\>##g; s#\<content_type\>.*\</content_type\>##g; s#\<publication_date\>.*\</publication_date\>##g; s#\<meta_data\><ASIN\>#<tr><td><a href="http://www.amazon.com/exec/obidos/ASIN/#g ; s#\</ASIN\>\<title\>#"> #g ; s#\</title\>#</a></td>#g; s#\<authors\>\<author\>#<td class="authors">#g; s#\</author\>\</authors\>#</td>#g; s#\<publishers\>\<publisher\>#<td class="publishers">#g; s#\</publisher\>\</publishers\>#</td>#g; s#\</meta_data\>#</tr>#g ; s#\</author\>\<author\>#, #g ; s#<publishers></publishers>#<td class="nopublisher">\&nbsp;#g ; ' |\
sed "s#WON'T GET FOOLED AGAIN THE WHO FROM LIFEHOUSE TO QUADROPHENIA#Won’t Get Fooled Again: The Who from Lifehouse to Quadrophenia#g" |\
sort --ignore-case -k 3 |\
sed G >> "$HTML"

#
#	Close the HTML file
#


cat <<EOINPUT >> "$HTML"
</table>

<p id='footer'>Last updated: $TIME</p>

</body>
</html>

EOINPUT

#
#	if ANY of SERVER or SERVER_FOLDER or URL are empty, then just open the file locally
#
if [ "$SERVER" = "" -o "$SERVER_FOLDER" = "" -o "$URL" = "" ]
then

		open -a "$BROWSER" "$HTML"
		exit 0

else

	# if we get here then SERVER and SERVER_FOLDER and URL are all set, so we'll try to
	# upload the file and then open the URL

		chmod 644 "$HTML"

		scp "$HTML" "$SERVER:$SERVER_FOLDER/index.html" && open -a "$BROWSER" "$URL" && exit 0

		# if we get here, the script didn't exit properly, so try opening local copy instead

		open -a "$BROWSER" "$HTML"

		exit 1
fi

exit
#
#EOF
