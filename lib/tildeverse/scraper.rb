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
      scrape_modified_dates
      save_tildeverse_json
      save_users_json
      save_index_html
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
    # Read in the tildebox names from the JSON.
    # Add current date and time to the hash.
    # This is the object that holds the full state.
    #
    # @return [Hash]
    #
    def json
      return @json if @json
      @json = Tildeverse::Files.input_tildeverse
      @json['metadata']['date_human'] = Time.now.strftime('%Y-%m-%d %H:%M:%S')
      @json['metadata']['date_unix']  = Time.now.to_i
      @json
    end

    ##
    # Add new users to the hash, for all sites.
    # Use existing data, or create new if necessary.
    #
    def scrape_new_users
      Tildeverse::Site.classes.each do |klass|
        tilde_site = klass.new
        users = tilde_site.users
        site_hash = json['sites'][tilde_site.name]
        site_hash['online']     = !users.empty?
        site_hash['user_count'] = users.size

        user_hash = {}
        users.each do |user|
          user_hash[user] = site_hash.dig('users', user) || {}
          user_hash[user][:time] = '-'
        end
        site_hash['users'] = user_hash
      end
    end

    ##
    # Add the date each user page was modified.
    #
    def scrape_modified_dates
      Tildeverse::ModifiedDates.new.data.each do |i|
        user_deets = json['sites'][i[:site]]['users'][i[:user]]
        user_deets[:time] = i[:time] if user_deets
      end
    end

    ##
    # Write the hash to 'tildeverse.json'.
    #
    def save_tildeverse_json
      file = Tildeverse::Files.output_json_tildeverse
      Tildeverse::Files.save_json(json, file)
    end

    ##
    # Write 'users.json' for backwards compatibility.
    #
    # Used by http://tilde.town/~insom/modified.html
    #
    def save_users_json
      users_hash = {}
      json['sites'].each_value do |value|
        site_hash = {}
        value['users'].each_key do |user|
          site_hash[user] = value['url_format_user'].sub('USER', user)
        end
        users_hash[value['url_root']] = site_hash
      end
      file = Tildeverse::Files.output_json_users
      Tildeverse::Files.save_json(users_hash, file)
    end

    ##
    # Update the timestamp in 'index.html'.
    #
    def save_index_html
      File.open(Tildeverse::Files.output_html_index, 'w') do |fo|
        File.open(Tildeverse::Files.input_html_template, 'r') do |fi|
          time_stamp = Time.now.strftime('%Y/%m/%d %H:%M GMT')
          out = fi.read.gsub('<!-- @TIME_STAMP -->', time_stamp)
          fo.puts out
        end
      end
    end

    ##
    # Copy all static files to the output directory.
    #
    def copy_static_files
      Tildeverse::Files.files_to_copy.each do |i|
        from = "#{Tildeverse::Files.dir_input}/#{i}"
        to   = "#{Tildeverse::Files.dir_output}/#{i}"
        FileUtils.cp(from, to)
      end
    end
  end
end
