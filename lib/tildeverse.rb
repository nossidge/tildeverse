#!/usr/bin/env ruby

require 'net/http'
require 'net/https'
require 'open-uri'
require 'json'
require 'fileutils'

require_relative 'tildeverse/core_extensions/string'
require_relative 'tildeverse/wsv'
require_relative 'tildeverse/files'
require_relative 'tildeverse/remote_resource'
require_relative 'tildeverse/user_serializer'
require_relative 'tildeverse/site_serializer'
require_relative 'tildeverse/data_serializer'
require_relative 'tildeverse/user'
require_relative 'tildeverse/site'
require_relative 'tildeverse/data'
require_relative 'tildeverse/sites'
require_relative 'tildeverse/modified_dates'
require_relative 'tildeverse/pfhawkins'
require_relative 'tildeverse/scraper'
require_relative 'tildeverse/fetcher'
require_relative 'tildeverse/version'

# Fixes bug with 'open-uri' not using 'tempfile' correctly.
# 'could not find a temporary directory (ArgumentError)'
ENV['TMPDIR'] = Tildeverse::Files.dir_output.to_s

################################################################################

##
# Download and output lists of the servers and users in the Tildeverse.
#
module Tildeverse
  class << self
    ##
    # Reference to the {Tildeverse::Data} instance
    #
    def data
      @data ||= Tildeverse::Data.new
    end

    ##
    # (see Tildeverse::Data#sites)
    #
    def sites
      data.sites
    end

    ##
    # (see Tildeverse::Data#site)
    #
    def site(site_name)
      data.site(site_name)
    end

    ##
    # (see Tildeverse::Data#users)
    #
    # Since this is the 'public' interface for the data, only return those
    # users who are online.
    #
    def users
      data.users.select(&:online?)
    end

    ##
    # (see Tildeverse::Data#user)
    #
    # Since this is the 'public' interface for the data, only return those
    # users who are online.
    #
    def user(user_name)
      data.user(user_name).select(&:online?)
    end

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
    # (see Tildeverse::Data#save)
    #
    def save
      data.save
    end

    ##
    # Run both {Tildeverse::Data#save} and {Tildeverse::Data#save_website}
    #
    def save!
      data.save
      data.save_website
    end
  end
end
