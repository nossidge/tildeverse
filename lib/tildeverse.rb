#!/usr/bin/env ruby

require 'net/http'
require 'net/https'
require 'open-uri'
require 'json'
require 'fileutils'

require_relative 'tildeverse/core_extensions/string'
require_relative 'tildeverse/files'
require_relative 'tildeverse/remote_resource'
require_relative 'tildeverse/site'
require_relative 'tildeverse/tilde_site'
require_relative 'tildeverse/site_scrapers'
require_relative 'tildeverse/modified_dates'
require_relative 'tildeverse/pfhawkins'
require_relative 'tildeverse/scraper'
require_relative 'tildeverse/fetcher'
require_relative 'tildeverse/patcher'
require_relative 'tildeverse/version'

################################################################################

##
# Download and output lists of the servers and users in the Tildeverse.
#
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
      {}
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
    # (see Tildeverse::Scraper#scrape)
    #
    def scrape
      Tildeverse::Scraper.new.scrape
    end

    ##
    # (see Tildeverse::Fetcher#fetch)
    #
    def fetch
      Tildeverse::Fetcher.new.fetch
    end

    ##
    # (see Tildeverse::Patcher#patch)
    #
    def patch
      Tildeverse::Patcher.new.patch
    end
  end
end
