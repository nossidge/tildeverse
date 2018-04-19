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
      scrape_new_users
      save_tildeverse_json
      save_users_json
      copy_static_files
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
    # Use existing data, or create new if necessary.
    #
    def scrape_new_users
      Tildeverse::Site.classes.each do |klass|
        site = klass.new
        site.users
      end
    end

    ##
    # Write the hash to 'tildeverse.json'.
    #
    def save_tildeverse_json
      json = Tildeverse.data.serialize_tildeverse_json
      file = Tildeverse::Files.output_json_tildeverse
      Tildeverse::Files.save_json(json, file)
    end

    ##
    # Write 'users.json' for backwards compatibility.
    #
    # Used by http://tilde.town/~insom/modified.html
    #
    def save_users_json
      json = Tildeverse.data.serialize_users_json
      file = Tildeverse::Files.output_json_users
      Tildeverse::Files.save_json(json, file)
    end

    ##
    # Copy all static files to the output directory.
    #
    def copy_static_files
      Tildeverse::Files.files_to_copy.each do |f|
        from = Tildeverse::Files.dir_input  + f
        to   = Tildeverse::Files.dir_output + f
        FileUtils.cp(from, to)
      end
    end
  end
end
