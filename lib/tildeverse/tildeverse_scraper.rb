#!/usr/bin/env ruby

module Tildeverse
  #
  # Scrape all Tilde sites and save as JSON files.
  class TildeverseScraper
    def scrape
      scrape_new_users
      scrape_modified_dates
      save_tildeverse_json
      save_users_json
      save_index_html
      copy_static_files
    end

    # Read in the tildebox names from the JSON.
    # Add current date and time to the hash.
    # This is the object that holds the full state.
    def json
      return @json if @json
      @json = Tildeverse::Config.input_tildeverse
      @json['metadata']['date_human'] = Time.now.strftime('%Y-%m-%d %H:%M:%S')
      @json['metadata']['date_unix']  = Time.now.to_i
      @json
    end

    # The class name is based on the site name.
    #   i.e. 'myrtle-st.club' => 'MyrtleStClub'
    # If the site is no longer online, it is moved to '/site_scrapers/dead/'
    #   and is not required by ruby. We can return an empty array for these.
    def site_users(site_name)
      @site_users ||= {}
      return @site_users[site_name] if @site_users[site_name]
      class_name = site_name.split(/\W/).map(&:capitalize).join
      @site_users[site_name] = begin
        Tildeverse.const_get(class_name).new.users
      rescue NameError
        []
      end
    end

    # Add new users to the hash, for all sites.
    # Use existing data, or create new if necessary.
    def scrape_new_users
      json['sites'].each do |site_name, site_hash|
        users = site_users(site_name)
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

    # Add the date each user page was modified.
    def scrape_modified_dates
      Tildeverse::ModifiedDates.new.get.each do |i|
        user_deets = json['sites'][i[:site]]['users'][i[:user]]
        user_deets[:time] = i[:time] if user_deets
      end
    end

    # Write the hash to 'tildeverse.json'.
    def save_tildeverse_json
      File.open(Tildeverse::Config.output_json_tildeverse, 'w') do |f|
        f.write JSON.pretty_generate(json)
      end
    end

    # Write 'users.json' for backwards compatibility.
    def save_users_json
      users_hash = {}
      json['sites'].each_value do |value|
        site_hash = {}
        value['users'].each_key do |user|
          site_hash[user] = value['url_format_user'].sub('USER', user)
        end
        users_hash[value['url_root']] = site_hash
      end
      File.open(Tildeverse::Config.output_json_users, 'w') do |f|
        f.write JSON.pretty_generate(users_hash)
      end
    end

    # Update the timestamp in 'index.html'.
    def save_index_html
      File.open(Tildeverse::Config.output_html_index, 'w') do |fo|
        File.open(Tildeverse::Config.input_html_template, 'r') do |fi|
          time_stamp = Time.now.strftime('%Y/%m/%d %H:%M GMT')
          out = fi.read.gsub('<!-- @TIME_STAMP -->', time_stamp)
          fo.puts out
        end
      end
    end

    # Copy all static files to the output directory.
    def copy_static_files
      Tildeverse::Config.files_to_copy.each do |i|
        from = "#{Tildeverse::Config.dir_data}/#{i}"
        to   = "#{Tildeverse::Config.dir_html}/#{i}"
        FileUtils.cp(from, to)
      end
    end
  end
end
