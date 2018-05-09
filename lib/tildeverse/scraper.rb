#!/usr/bin/env ruby

require 'fileutils'

module Tildeverse
  ##
  # Scrape all Tilde sites and save as JSON files.
  #
  class Scraper
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
      Tildeverse.save!
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
        Tildeverse::Files.dir_output,
        Tildeverse::Files.output_json_tildeverse,
        Tildeverse::Files.output_json_users,
        Tildeverse::Files.output_html_index
      ]
      Tildeverse::Files.write?(files)
    end

    ##
    # Add new users to the hash, for all sites.
    #
    def scrape_all_sites
      Tildeverse.sites.each(&:scrape)
    end

    ##
    # Update modified date for all users.
    #
    def update_mod_dates
      mod_dates = ModifiedDates.new
      Tildeverse.data.users.each do |user|
        date = mod_dates.for_user(user.site.name, user.name) || '-'
        user.date_modified = date
      end
    end
  end
end
