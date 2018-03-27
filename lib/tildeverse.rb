#!/usr/bin/env ruby

require 'net/http'
require 'net/https'
require 'open-uri'
require 'json'
require 'fileutils'

require_relative 'tildeverse/core_extensions/string'
require_relative 'tildeverse/files'
require_relative 'tildeverse/remote_resource'
require_relative 'tildeverse/tilde_site'
require_relative 'tildeverse/site_scrapers'
require_relative 'tildeverse/modified_dates'
require_relative 'tildeverse/tildeverse_scraper'
require_relative 'tildeverse/pfhawkins'
require_relative 'tildeverse/version'

################################################################################

# Download and output lists of the servers and users in the Tildeverse.
module Tildeverse
  class << self
    ##
    # @return [Hash] the data in the file {Files.output_json_tildeverse}.
    # @raise [IOError] if the file is not found.
    #
    def data
      obj = Tildeverse::Files.output_tildeverse
      return obj unless obj.empty?
      msg = 'JSON file not found. Run method #scrape or #fetch to create.'
      raise IOError, msg
    end

    ##
    # Return the users for all sites, or for a given site.
    # @param [String] site_name
    #   Only list users of the given server.
    # @return [Hash] If +site_name+ is present.
    #   Pulled directly from the file {Files.output_json_tildeverse}.
    # @return [Array<String>] If no +site_name+ is present.
    #   A list of all user URLs in the Tildeverse.
    #
    def users(site_name = nil)
      if site_name
        data.dig('sites', site_name, 'users')
      else
        data['sites'].map do |_, site_hash|
          site_hash['users'].each_key.map do |user|
            site_hash['url_format_user'].sub('USER', user)
          end
        end.flatten
      end
    end

    ##
    # @param [Boolean] include_offline
    #   Include servers known to be offline.
    # @return [Array<String>] a list of the server names.
    # @example
    #   [
    #     'backtick.town',
    #     'botb.club',
    #     'crime.team',
    #     'ctrl-c.club',
    #     'hackers.cool'
    #   ]
    #
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

    ##
    # (see Tildeverse::PFHawkins#new?)
    #
    def new?
      Tildeverse::PFHawkins.new.new?
    end

    ##
    # (see Tildeverse::TildeverseScraper#scrape)
    #
    def scrape
      Tildeverse::TildeverseScraper.new.scrape
    end

    ##
    # Fetch the up-to-date JSON file from the remote URI.
    # @return [Boolean] success state.
    #
    def fetch
      tf = Tildeverse::Files

      # Error message and return if user has no write permissions.
      files = [
        tf.output_json_tildeverse,
        tf.input_json_tildeverse
      ]
      return false unless tf.write?(files)

      info = ['remote_json', tf.remote_json]
      tc = Tildeverse::RemoteResource.new(*info)
      tc.get
      puts tc.msg or return false if tc.error

      tf.save_text(tc.result, tf.output_json_tildeverse)
      update_input_from_output
      true
    end

    ##
    # Update user tags from 'dir_input' to 'dir_output'.
    #
    # Run this after you have done manual user tagging in the input JSON.
    # It will update the output JSON without doing the full site-scrape.
    #
    # @return [Boolean] success state.
    #
    def patch
      tf = Tildeverse::Files

      # Error message and return if user has no write permissions.
      files = [tf.output_json_tildeverse]
      return false unless tf.write?(files)

      # This is the JSON object that will be updated.
      output = tf.output_tildeverse

      # Only need to update the users that exist in the output file.
      tf.input_tildeverse['sites'].each do |site, site_hash|
        [*site_hash['users']].each do |user, user_hash|
          begin
            output['sites'][site]['users'][user]['tagged'] = user_hash['tagged']
            output['sites'][site]['users'][user]['tags']   = user_hash['tags']
          rescue NoMethodError
          end
        end
      end

      # Update the 'output' JSON.
      tf.save_json(output, tf.output_json_tildeverse)
      true
    end

    private

    ##
    # Update the 'input' JSON from the 'output' JSON.
    # This seems a bit backward, but it makes sense, honest.
    #
    # @return [nil]
    #
    def update_input_from_output
      tf   = Tildeverse::Files
      from = tf.output_tildeverse
      to   = tf.input_tildeverse

      # Copy the metadata url.
      to['metadata']['url'] = from['metadata']['url']

      # Copy just the new users.
      from['sites'].each_key do |site|
        hash_to   = to  ['sites'][site]
        hash_from = from['sites'][site]

        # Copy the whole structure if the site doesn't already exist.
        if hash_to.nil?
          to['sites'][site] = from['sites'][site]
          next
        end

        # Update each user, if remote is more recent.
        update_input_users_from_output!(hash_to, hash_from)

        # Update the url fields.
        %w[url_root url_list url_format_user].each do |field|
          hash_to[field] = hash_from[field]
        end
      end

      # Update the 'input' JSON.
      tf.save_json(to, tf.input_json_tildeverse)
    end

    ##
    # Update each user. Changes the values of the hash inputs.
    #
    # @param [Hash] hash_to
    #   Hash to read from.
    # @param [Hash] hash_from
    #   Hash to write to.
    # @return [nil]
    #
    def update_input_users_from_output!(hash_to, hash_from)
      hash_from['users'].each_key do |user|
        #
        # Copy the whole structure if the user doesn't already exist.
        # But don't get users that don't yet have tags.
        if hash_to['users'][user].nil?
          unless hash_from['users'][user]['tags'].nil?
            hash_to['users'][user] = hash_from['users'][user]
            hash_to['users'][user].delete('time')
          end
          next
        end

        # Only update the tags if the 'tagged' date is greater.
        tagged_to   = hash_to  ['users'][user]['tagged'] || '1970-01-01'
        tagged_from = hash_from['users'][user]['tagged'] || '1970-01-01'
        date_to     = Date.strptime(tagged_to,   '%Y-%m-%d')
        date_from   = Date.strptime(tagged_from, '%Y-%m-%d')
        hash_to['users'][user]['tagged'] = tagged_from if date_to < date_from
      end
    end
  end
end
