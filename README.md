# Tildeverse Users

by Paul Thompson - nossidge@gmail.com

Generate a list of all users in the [Tildeverse][pfhawkins].

The code will scrape the HTML or JSON user lists served by each site, and collate them together in one place.

There's also a manual component, where I attempt to categorise each user's public HTML page.

Output to [JSON][json], with [web front-end][web] to view data in table form.

[pfhawkins]: http://tilde.club/~pfhawkins/othertildes.html
[web]: https://tilde.town/~nossidge/tildeverse/
[json]: https://tilde.town/~nossidge/tildeverse/tildeverse.json


## CLI Usage

```
  Usage: tildeverse <command> [regex] [options]

$ tildeverse scrape
  Scrape the user list of each box, and generate the JSON files

$ tildeverse fetch
  Fetch data from tilde.town/~nossidge/tildeverse/tildeverse.json

$ tildeverse new
  See if there have been any additions by ~pfhawkins

$ tildeverse json [-p]
  Write the full JSON file to standard out

$ tildeverse sites [regex] [-l] [-j -p]
  List all online sites in the Tildeverse
  'regex' argument filters URLs by regex

$ tildeverse site [regex] [-l] [-j -p]
  List all users for the specified Tildebox
  'regex' argument filters URLs by regex

$ tildeverse user [regex] [-l] [-j -p]
  or
$ tildeverse [regex] [-l] [-j -p]
  List all the users by URL
  'regex' argument filters URLs by regex

[options]
  -l  output in long listing format
  -j  output in JSON format
  -p  output in pretty JSON format
```


## User Page Tags

Each site in the Tildeverse has been tagged with the approximate content of the site. This was all done by hand by me, not the users themselves.

```
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
```

To add or edit these tags you can manually alter `data/tildeverse.txt`, but I have also created a browser-based GUI to help with this. It looks like [this](https://i.imgur.com/WmARw0C.jpg).

If you run `rackup`, a single-page web app will be created. Point your browser to `localhost:4567` and scroll through the sites. The tags are displayed as toggle-able buttons on the left-hand side. Click the 'save' button to save changes back to the JSON file.

I appreciate any pull requests regarding changes to these tags. 2500 websites is a lot to handle, and I'm certain I've made some mistakes.
