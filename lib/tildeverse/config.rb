#!/usr/bin/env ruby

require 'yaml'

module Tildeverse
  ##
  # Config information, including date of most recent update.
  # Reads from file 'config/config.yml'.
  #
  class Config
    ##
    # Method to use when GETting data from the Internet.
    # @return [String] either 'scrape' or 'fetch'
    #
    attr_reader :get_type

    ##
    # @return [Date] date the data was last updated
    #
    attr_reader :updated_on

    ##
    # Load data from 'config.yml' if the file exists.
    # If it does not exist, create new file using default values.
    #
    def initialize
      if filepath.exist?
        data = YAML.safe_load(filepath.read, [Date])
        self.get_type = data['get_type']
        @updated_on   = data['updated_on']
      else
        @get_type   = 'fetch'
        @updated_on = Date.new(1970, 1, 1)
      end
      save
    end

    ##
    # @param [String] input
    #
    def get_type=(input)
      unless types_of_get.include?(input)
        raise ArgumentError, "Value must be one of: #{types_of_get.join(', ')}"
      end
      @get_type = input
      save
    end

    ##
    # Set {#updated_on} to today's date.
    #
    def update
      @updated_on = Date.today
      save
    end

    ##
    # Save config settings to file.
    #
    def save
      str = yaml_template
      %w[get_type updated_on].each do |var|
        str.sub!("@#{var}@", "#{var}:\n  #{send(var)}")
      end
      Files.save_text(str, filepath)
    end

    private

    ##
    # File path of the config YAML. Creates directory if not yet existing.
    #
    def filepath
      dir_config = Files.dir_root + 'config'
      Files.makedirs(dir_config) unless dir_config.exist?
      dir_config + 'config.yml'
    end

    ##
    # @return [Array<String>]
    #
    def types_of_get
      %w[scrape fetch]
    end

    ##
    # Template for the YAML output.
    # We cannot use 'to_yaml' as it does not preserve comments.
    # @return [String]
    #
    def yaml_template
      <<-YAML.gsub(/^ {6}/, '')
      # Determines how data is gathered from the remote servers.
      # Can be either 'scrape' or 'fetch'.
      # 'scrape' => Return live results by scraping each site in the Tildeverse.
      # 'fetch'  => (RECOMMENDED) Return daily pre-scraped results from the file
      #             at tilde.town. This is run every day at midnight, so the
      #             results will likely be more accurate than manual scraping.
      @get_type@

      # The date that the data was last updated.
      # Should be in the form: 'YYYY-MM-DD'
      @updated_on@
      YAML
    end
  end
end
