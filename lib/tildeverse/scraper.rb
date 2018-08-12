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
    # Return false if the user does not have the correct write permissions.
    #
    # @return [Boolean] success state.
    #
    def scrape
      return false unless write_permissions?
      scrape_all_sites
      update_mod_dates
      data.save_with_config
      true
    end

    private

    ##
    # Check whether the current user has the correct OS permissions
    # to write to the output files.
    #
    # @return [Boolean]
    #
    def write_permissions?
      files = [
        Files.dir_output,
        Files.output_json_tildeverse,
        Files.output_json_users,
        Files.output_html_index
      ]
      Files.write?(files)
    end

    ##
    # Add new users to the hash, for all sites.
    #
    def scrape_all_sites
      data.sites.map do |s|
        Thread.new(s) do |site|
          site.scrape
        end
      end.each(&:join)
    end

    ##
    # Update modified date for all users.
    #
    def update_mod_dates
      mod_dates = ModifiedDates.new
      data.users.each do |user|
        date = mod_dates.for_user(user.site.name, user.name) || '-'
        user.date_modified = date
      end
    end
  end
end
