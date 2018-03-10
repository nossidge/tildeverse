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
      update_input_from_output
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

      # Update the 'output' JSON.
      save_json(output, Tildeverse::Config.output_json_tildeverse)
    end

    private

    # Update the 'input' JSON from the 'output' JSON.
    # This seems a bit backward, but it makes sense, honest.
    def update_input_from_output
      from = Config.output_tildeverse
      to   = Config.input_tildeverse

      # Copy the metadata exactly.
      to['metadata'] = from['metadata']

      # Copy just the new users.
      from['sites'].each_key do |site|
        hash_to   = to  ['sites'][site]
        hash_from = from['sites'][site]

        # Copy the whole structure if the site doesn't already exist.
        if hash_to.nil?
          hash_to = hash_from
          next
        end

        # Update the url fields.
        %w[url_root url_list url_format_user].each do |field|
          hash_to[field] = hash_from[field]
        end
      end

      # Update the 'input' JSON.
      save_json(to, Tildeverse::Config.input_json_tildeverse)
    end

    # Update each user.
    def update_input_users_from_output
      hash_from['users'].each_key do |user|
        #
        # Copy the whole structure if the user doesn't already exist.
        if hash_to['users'][user].nil?
          hash_to['users'][user] = hash_from['users'][user]
          hash_to['users'][user].delete('time')
          next
        end

        # Only update the tags if the 'tagged' date is greater.
        tagged_to   = hash_to  ['users'][user]['tagged']
        tagged_from = hash_from['users'][user]['tagged']
        date_to     = Date.strptime(tagged_to,   '%Y-%m-%d')
        date_from   = Date.strptime(tagged_from, '%Y-%m-%d')
        hash_to['users'][user]['tagged'] = tagged_from if date_to > date_from
      end
    end

    # Save a hash to a JSON file.
    def save_json(hash_obj, filepath)
      File.open(filepath, 'w') do |f|
        f.write JSON.pretty_generate(hash_obj).force_encoding('UTF-8')
      end
    end
  end
end
