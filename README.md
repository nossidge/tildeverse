# Tildeverse Users Scraper

by Paul Thompson - nossidge@gmail.com

Generate a list of all users in the Tildeverse.

Mostly done using HTML scraping, but there are few JSON feeds.

Output to JSON, with web front-end to view data in table form.


## Output

https://tilde.town/~nossidge/tildeverse/

https://tilde.town/~nossidge/tildeverse/tildeverse.json


## CLI Usage

````
Usage: tildeverse <command> [subcommand]

$ tildeverse scrape
  Scrape the user list of each box, and output to JSON

$ tildeverse json ['pretty']
  Write the JSON file to standard out
  'pretty' subcommand adds new lines

$ tildeverse sites|boxes
  List all the sites in the Tildeverse

$ tildeverse [site name] ['json']
  List all users for the specified Tildebox
  'json' subcommand outputs as JSON
````


## User Page Tags

Each site in the Tildeverse has been tagged with the approximate content of the site. This was all done by hand by me, not the users themselves.

````
empty      No content / default index.html
brief      Not a lot of content
redirect   No content; page just links to elsewhere on the Web
links      Links to personal sites elsewhere
blog       An old-fashioned weblog
poetry     Verse in any form
prose      Fiction or nonfiction, in sufficient quantity
art        Any form of art. Includes ASCII, JS and HTML. Words can be art
photo      Photography
audio      Music, spoken word, sound
video      Moving pictures
gaming     Stuff about games
tutorial   An in-depth guide to a topic
app        Web application of any kind
code       Contains actual code samples/projects
procgen    Procedurally generated art/poetry/music/whatever
web1.0     Early web aesthetic
unix       Unix and terminal
tilde      Meta stuff, to do with the Tildeverse
````

To add or edit these tags you can manually alter `data/tildeverse.json`, but I have also created a browser-based GUI to help with this. It looks like [this](https://i.imgur.com/WmARw0C.jpg).

If you run `rackup`, a single-page web app will be created. Point your browser to `localhost:4567` and scroll through the sites. The tags are displayed as toggle-able buttons on the left-hand side. Click the 'save' button to save changes back to the JSON file.

I appreciate any pull requests regarding changes to these tags. 2500 websites is a lot to handle, and I'm certain I've made some mistakes.
