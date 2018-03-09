#!/usr/bin/env ruby

require 'net/http'
require 'net/https'
require 'open-uri'
require 'json'
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

# Download and output lists of the servers and users in the Tildeverse.
module Tildeverse
  class << self
    #
    # All the data in the tildeverse JSON file.
    def data
      obj = Config.output_tildeverse
      return obj unless obj.empty?
      msg = 'JSON file not found. Run method #scrape or #fetch to create.'
      raise IOError, msg
    end

    # Return the users hash for all sites, or for a given site.
    def users(site_name = nil)
      if site_name
        data.dig('sites', site_name, 'users')
      else
        data['sites'].map do |_, site_hash|
          site_hash['users'].each_key.map do |user|
            site_hash['url_format_user'].sub('USER', user)
          end
        end
      end
    end

    # Return an array of the server names.
    def servers(include_offline = false)
      if include_offline
        data['sites'].keys
      else
        data['sites'].select do |_, site_hash|
          site_hash['online']
        end.keys
      end
    end
    alias sites servers
    alias boxes servers

    # Boolean for if a new Tilde server has been added by ~pfhawkins.
    def new?
      Tildeverse::PFHawkins.new.new?
    end

    # Scrape all the sites for users.
    def scrape
      Tildeverse::TildeverseScraper.new.scrape
    end

    # Fetch the up-to-date JSON file from the remote URI.
    def fetch
      remote_json = Tildeverse::Config.remote_json
      info = ['remote_json', remote_json]
      tc = Tildeverse::TildeConnection.new(*info)
      tc.get
      if tc.error
        puts tc.error_message
        return
      end
      File.open(Tildeverse::Config.output_json_tildeverse, 'w') do |f|
        f.write tc.result
      end
    end

    # Update user tags from 'dir_data' to 'dir_html'.
    # Run this after you have done manual user tagging in the input JSON.
    # It will update the output JSON without doing the full site-scrape.
    def patch
      output = Tildeverse::Config.output_tildeverse

      # Only need to update the users that exist in the output file.
      Tildeverse::Config.input_tildeverse['sites'].each do |site, site_hash|
        [*site_hash['users']].each do |user, user_hash|
          begin
            output['sites'][site]['users'][user]['tagged'] = user_hash['tagged']
            output['sites'][site]['users'][user]['tags']   = user_hash['tags']
          rescue NoMethodError
          end
        end
      end

      File.open(Tildeverse::Config.output_json_tildeverse, 'w') do |f|
        f.write JSON.pretty_generate(output).force_encoding('UTF-8')
      end
    end
  end
end
