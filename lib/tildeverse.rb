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
require_relative 'tildeverse/config'
require_relative 'tildeverse/tilde_connection'
require_relative 'tildeverse/tilde_site'
require_relative 'tildeverse/site_scrapers'
require_relative 'tildeverse/modified_dates'
require_relative 'tildeverse/tildeverse_scraper'
require_relative 'tildeverse/pfhawkins'

################################################################################

WRITE_TO_FILES          = true   # This is necessary.
CHECK_FOR_NEW_BOXES     = false  # This is fast.

################################################################################

module Tildeverse
  def self.run_all
    Tildeverse::TildeverseScraper.new.scrape if WRITE_TO_FILES
    Tildeverse::PFHawkins.new.puts_if_new if CHECK_FOR_NEW_BOXES
  end
end

################################################################################
