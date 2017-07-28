# Tildeverse Users Scraper

by Paul Thompson - nossidge@gmail.com

https://tilde.town/~nossidge/tildeverse/

Get a list of all users in the Tildeverse.

Mostly done using HTML scraping, but there are few JSON feeds.

This was originally just a single script; I'm still in the process of separating it to a repo.


## History

````
2014/12/22  Initial. Scrapes all Tildeboxes from the master list:
            http://tilde.club/~pfhawkins/othertildes.html
2014/12/28  Add JSON user list: protocol.club/~insom/protocol.24h.json
2015/01/03  New Tildebox: club6.nl
            New Tildebox: losangeles.pablo.xyz
2015/01/04  Add HTML user list: club6.nl/index.html
2015/01/05  Include http/https protocol info in JSON
            Add oldbsd.club to JSON, even though there's no user info
2015/01/06  Check each Tildebox to see if they have a '/tilde.json' file
            Add JSON user list: club6.nl/tilde.json
            Add JSON user list: squiggle.city/tilde.json
            Add JSON user list: yester.host/tilde.json
2015/01/08  Create backup of HTML and JSON files so can revert if necessary
2015/01/15  Add HTML user list: losangeles.pablo.xyz/index.html
2015/01/19  Fix HTML user list: noiseandsignal.com/index.html
2015/03/05  RIP: drawbridge.club (merged into tilde.town)
            RIP: germantil.de
            RIP: noiseandsignal.com
2015/06/13  Add class TildeConnection for connection error handling
              We will now be able to schedule this script in cron
              Also can now determine the exact date of future site 404s
            RIP: drawbridge.club
            RIP: losangeles.pablo.xyz
            RIP: sunburnt.country
            RIP: tilde.center
            RIP: tilde.city
            RIP: tilde.farm
            RIP: yester.host
2015/08/09  RIP: catbeard.city
2015/10/05  RIP: bleepbloop.club
2015/10/11  RIP: tilde.camp
2015/10/13  RIP: hypertext.website
2015/11/13  Add error handling to method check_for_new_desc_json
            Add JSON user list: ctrl-c.club/tilde.json
2015/11/17  New Tildebox: perispomeni.club
2016/01/13  Fix problem with using JSON.parse on strings containing tabs
            squiggle.city is now HTTPS, not HTTP
            RIP: club6.nl
2016/02/04  RIP: matilde.club
2016/02/23  RIP: totallynuclear.club
2016/02/24  RIP: tilde.red
2016/02/26  Added Twitter integration
2016/08/05  tilde.town JSON is incomplete, so merge with index.html user list
2016/08/10  New Tildebox: spookyscary.science
2016/08/14  RIP: retronet.net
            Back: tilde.red
            tilde.town now using https
2016/09/12  RIP: cybyte.club
            New Tildebox: botb.club
            Use 'Net::HTTP.get URI(url)' instead of 'open-uri'
              This should fix certain HTTPS errors
            Fix string encoding issues. Should now all be in 'UTF-8'
2017/04/11  Update: protocol.club
            New Tildebox: crime.team
            New Tildebox: backtick.town
            New Tildebox: ofmanytrades.com
````
