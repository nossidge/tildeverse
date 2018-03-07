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
require_relative 'tildeverse/pfhawkins'

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

################################################################################

module Tildeverse

################################################################################

def self.output_to_files
  Tildeverse::TildeverseScraper.new.scrape
end

################################################################################

def self.check_for_new_boxes
  pfhawkins = Tildeverse::PFHawkins.new
  puts pfhawkins.new_message if pfhawkins.new?
end

################################################################################

def self.run_all
  output_to_files if WRITE_TO_FILES
  check_for_new_boxes if CHECK_FOR_NEW_BOXES
end

################################################################################

end

################################################################################
