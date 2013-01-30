Pop Charts Little Printer Publication
===========

This is a Little Printer publication that uses the iTunes RSS feeds to get chart data for various countries. It is written in Sinatra.

Routes
------

* `/edition/` - The main content of the publication. The only variable is which country you require charts from. Since not every country has an iTunes music store, it won't work with all of them.

* `/sample/` - The sample publication.

* `/validate_config/` - Validates the configuration sent by Bergcloud when the publication is first subscribed to.

* `/meta.json/` - The json array containing the publication's meta data. 

Views
-----

* `littlenew.erb` - For when there is a chart change or no row in the database for supplied country (Also contains code to save to database)

* `littleold.erb` - Gets row from database for supplied country

* `meta.erb` - Metadata json array

Feed
----

`https://itunes.apple.com/[two letter country code]/rss/topsongs/limit=5/xml` -  The url for the rss feed which contains the iTunes chart.