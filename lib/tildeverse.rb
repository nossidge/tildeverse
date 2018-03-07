#!/usr/bin/env ruby

################################################################################
# Tildeverse Users Scraper
################################################################################
# Get a list of all users in the Tildeverse.
# Mostly done using HTML scraping, but there are few JSON feeds.
################################################################################

require 'net/http'
require 'net/https'
require 'open-uri'
require 'json'
require 'text/hyphen'
require 'fileutils'

require_relative 'tildeverse/core_extensions/string'
require_relative 'tildeverse/tilde_connection'
require_relative 'tildeverse/tilde_site'
require_relative 'tildeverse/site_scrapers'
require_relative 'tildeverse/modified_dates'
require_relative 'tildeverse/tildeverse_scraper'

################################################################################

DIR_ROOT                = File.expand_path('../../', __FILE__)
DIR_DATA                = "#{DIR_ROOT}/data"
DIR_HTML                = "#{DIR_ROOT}/output"

INPUT_HTML_TEMPLATE     = "#{DIR_DATA}/index_template.html"
INPUT_JSON_TILDEVERSE   = "#{DIR_DATA}/tildeverse.json"
INPUT_TILDEVERSE        = JSON[
                            File.read(
                              INPUT_JSON_TILDEVERSE,
                              external_encoding: 'utf-8',
                              internal_encoding: 'utf-8'
                            )
                          ]

OUTPUT_HTML_INDEX       = "#{DIR_HTML}/index.html"
OUTPUT_JSON_TILDEVERSE  = "#{DIR_HTML}/tildeverse.json"
OUTPUT_JSON_USERS       = "#{DIR_HTML}/users.json"
FILES_TO_COPY           = ['users.js', 'boxes.js', 'pie.js']

WRITE_TO_FILES          = true   # This is necessary.
CHECK_FOR_NEW_BOXES     = false  # This is fast.
CHECK_FOR_NEW_DESC_JSON = false  # This is slow.

################################################################################

module Tildeverse

################################################################################

def self.output_to_files
  Tildeverse::TildeverseScraper.new.scrape
end

################################################################################

# ~pfhawkins JSON list of all other tildes.
# If this has been updated let me know. Then I can manually add the new box.
def self.scrape_all_tildes
  string_json = open('http://tilde.club/~pfhawkins/othertildes.json').read
  JSON[string_json].values.map do |i|
    i = i[0...-1] if i[-1] == '/'
    i.split('//').last
  end
end

def self.check_for_new_boxes
  return if scrape_all_tildes.length == 19
  puts '-- New Tilde Boxes!'
  puts 'http://tilde.club/~pfhawkins/othertildes.html'
end

################################################################################

# Check each Tildebox to see if they have a '/tilde.json' file.
# I already know that 3 do, so let me know if that number changes.
#   https://club6.nl/tilde.json
#   http://ctrl-c.club/tilde.json
#   https://squiggle.city/tilde.json
def self.check_for_tilde_json

  # Read from the master list of Tilde URLs, and append '/tilde.json' to them.
  obj_json = JSON[open(OUTPUT_JSON_TILDEVERSE).read]
  urls_json = obj_json.keys.map { |i| i + '/tilde.json' }

  # Only select the URLs that can be parsed as JSON.
  urls_json.select do |item|
    begin
      JSON[open(item).read]
      true
    rescue StandardError
      false
    end
  end
end

def self.check_for_new_desc_json
  tilde_desc_files = check_for_tilde_json
  return if tilde_desc_files.length == 3
  puts '-- Tilde Description JSON files:'
  puts tilde_desc_files
  puts nil
end

################################################################################

def self.run_all
  output_to_files if WRITE_TO_FILES
  check_for_new_boxes if CHECK_FOR_NEW_BOXES
  check_for_new_desc_json if CHECK_FOR_NEW_DESC_JSON
end

################################################################################

end

################################################################################
