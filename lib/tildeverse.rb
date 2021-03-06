#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'net/https'
require 'open-uri'
require 'fileutils'
require 'date'
require 'json'
require 'yaml'
require 'etc'

require_relative 'tildeverse/core_extensions/string'
require_relative 'tildeverse/core_extensions/pathname'
require_relative 'tildeverse/tilde_date'
require_relative 'tildeverse/error'
require_relative 'tildeverse/wsv'
require_relative 'tildeverse/files'
require_relative 'tildeverse/data_file'
require_relative 'tildeverse/config'
require_relative 'tildeverse/tilde_site_uri'
require_relative 'tildeverse/remote_resource'
require_relative 'tildeverse/user_serializer'
require_relative 'tildeverse/site_serializer'
require_relative 'tildeverse/data_serializer'
require_relative 'tildeverse/data_saver'
require_relative 'tildeverse/tag_array'
require_relative 'tildeverse/user'
require_relative 'tildeverse/site'
require_relative 'tildeverse/data'
require_relative 'tildeverse/sites'
require_relative 'tildeverse/modified_dates'
require_relative 'tildeverse/pfhawkins'
require_relative 'tildeverse/scraper'
require_relative 'tildeverse/fetcher'
require_relative 'tildeverse/tag_merger'
require_relative 'tildeverse/exception_suppressor'
require_relative 'tildeverse/version'

################################################################################

##
# Download and output lists of the servers and users in the Tildeverse
#
module Tildeverse
  class << self
    ##
    # Reference to the {Tildeverse::ExceptionSuppressor} instance
    #
    def suppress
      @suppress ||= Tildeverse::ExceptionSuppressor.new
    end

    ##
    # Reference to the {Tildeverse::Config} instance
    #
    def config
      @config ||= Tildeverse::Config.new
    end

    ##
    # Reference to the {Tildeverse::Data} instance
    #
    def data
      @data ||= Data.new(config)
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
    # users who are online
    #
    def users
      data.users.select(&:online?)
    end

    ##
    # (see Tildeverse::Data#user)
    #
    # Since this is the 'public' interface for the data, only return those
    # users who are online
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
    # Run {Tildeverse#get!} if it has not yet been run, according to the
    # settings in 'config.yml'
    #
    def get
      get! if config.update_required?
    end

    ##
    # Get data from remote servers.
    # Use the config setting to choose between 'scrape' and 'fetch'
    #
    # @raise [Error::UpdateTypeError] if {Config#update_type} is invalid
    #
    def get!
      {
        scrape: -> { scrape },
        fetch:  -> { fetch }
      }.fetch(config.update_type.to_sym) do
        raise Error::UpdateTypeError
      end.call
    end

    ##
    # (see Tildeverse::Scraper#scrape)
    #
    def scrape
      Tildeverse::Scraper.new(data).scrape
    end

    ##
    # (see Tildeverse::Fetcher#fetch)
    #
    def fetch
      Tildeverse::Fetcher.new(data).fetch
    end

    ##
    # (see Tildeverse::Data#save)
    #
    def save
      data.save
    end
  end
end
