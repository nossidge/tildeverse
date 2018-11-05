#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

module Tildeverse
  ##
  # Scrape all Tilde sites and save as JSON files.
  #
  class Scraper
    ##
    # @return [Data] the underlying Data object
    #
    attr_reader :data

    ##
    # @param [Data] data
    #
    def initialize(data)
      @data = data
    end

    ##
    # Scrape all Tilde sites and save as JSON files.
    #
    # Requires write-access to the underlying data files, so raises an error
    # if permission is denied.
    #
    # @raise [Error::DeniedByConfig]
    #   if user is not authorised for write-access by the config
    #
    def scrape
      raise Error::DeniedByConfig unless data.config.authorised?

      scrape_all_sites
      update_mod_dates
      data.save_with_config
    end

    private

    ##
    # Add new users to the hash, for all sites.
    #
    def scrape_all_sites
      data.sites.map(&:scrape)
    end

    ##
    # Update modified date for all users.
    #
    # If the user is no longer on the {ModifiedDates} list, then keep the
    # previous value.
    #
    def update_mod_dates(mod_dates = ModifiedDates.new)
      data.users.each do |user|
        mod_date = mod_dates.for_user(user.site.name, user.name)
        user.date_modified = mod_date if mod_date
      end
    end
  end
end
