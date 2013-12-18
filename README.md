kindleXML2HTML
==============

Zsh shell script to parse Kindle for Mac's cached Kindle book list and turn it into a web page

I wanted to make a quick and easy reference web page for my Kindle library, rather than having to page through it on Amazon.com or the Kindle itself.

I started looking at the [Kindle Mac app][1] because I figured that it had the information I wanted, I just needed to know if I could get at it easily enough. Turns out that I could, because the Kindle app for Mac stores a cache of your entire Kindle library (title, author, publisher, etc) in an XML file, which is saved at **$HOME/Library/Application Support/Kindle/Cache/KindleSyncMetadataCache.xml**

Then all I had to do is parse the XML file and reformat the output into HTML.

The end result of that attempt is this script.

* The HTML it creates is not particularly impressive, it's just plain text in an HTML table with some small amount of CSS.

* The book titles are linked to Amazon.com using Amazon's "ASIN" numbers. It has been assumed that each book's URL conforms to the normal pattern of <http://www.amazon.com/exec/obidos/ASIN/> followed by the ASIN itself, such as <http://www.amazon.com/exec/obidos/ASIN/B000OVLK2W>.

* The only information which is shown is the book title, author(s), and publishing company (if known/if any).

* The books are sorted by title, alphabetically, but the sort is pretty rudimentary. For example, book titles which begin with "A" or "The" will be sorted under A or T, respectively.



[1]: http://www.amazon.com/gp/kindle/mac/download‎

