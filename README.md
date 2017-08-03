# Tildeverse Users Scraper

by Paul Thompson - nossidge@gmail.com

Get a list of all users in the Tildeverse.

Mostly done using HTML scraping, but there are few JSON feeds.


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

$ tildeverse [site name]
  List all users for the specified Tildebox
````
