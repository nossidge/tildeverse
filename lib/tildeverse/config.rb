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
    # @return [true, false] should new data be automatically downloaded?
    #
    attr_reader :get_daily
    alias get_daily? get_daily

    ##
    # @return [true, false] should a website be generated?
    #
    attr_reader :generate_html
    alias generate_html? generate_html

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
        @get_type      = validate_get_type      data['get_type']
        @get_daily     = validate_get_daily     data['get_daily']
        @generate_html = validate_generate_html data['generate_html']
        @updated_on    = data['updated_on']
      else
        @get_type      = 'fetch'
        @get_daily     = true
        @generate_html = false
        @updated_on    = Date.new(1970, 1, 1)
      end
      save
    end

    ##
    # @param [String] value
    # @return [String] the input value
    # @raise [ArgumentError] if not valid
    #
    def get_type=(value)
      with(:save) { @get_type = validate_get_type(value) }
    end

    ##
    # @param [true, false] value
    # @return [true, false] the input value
    # @raise [ArgumentError] if not valid
    #
    def get_daily=(value)
      with(:save) { @get_daily = validate_get_daily(value) }
    end

    ##
    # @param [true, false] value
    # @return [true, false] the input value
    # @raise [ArgumentError] if not valid
    #
    def generate_html=(value)
      with(:save) { @generate_html = validate_generate_html(value) }
    end

    ##
    # Set {#updated_on} to today's date
    # @return [Date] today's date
    #
    def update
      with(:save) { @updated_on = Date.today }
    end

    ##
    # Save config settings to file.
    #
    def save
      str = yaml_template
      %w[get_type get_daily generate_html updated_on].each do |var|
        str.sub!("@#{var}@", "#{var}:\n  #{send(var)}")
      end
      Files.save_text(str, filepath)
    end

    private

    ##
    # Yield to a block, run a method, and return
    # the return value of the block.
    #
    def with(method_name)
      output = yield
      method(method_name).call
      output
    end

    ##
    # Validate that a value is within an array
    # @return [value] if valid
    # @raise [ArgumentError] if not valid
    #
    def validate_in_array(value, array)
      return value if array.include?(value)
      raise ArgumentError, "Value must be one of: #{array.join(', ')}"
    end

    ##
    # Validate {#get_type}
    # @return [String] if valid
    # @raise [ArgumentError] if not valid
    #
    def validate_get_type(value)
      validate_in_array(value, types_of_get)
    end

    ##
    # Validate {#get_daily}
    # @return [true, false] if valid
    # @raise [ArgumentError] if not valid
    #
    def validate_get_daily(value)
      validate_in_array(value, [true, false])
    end

    ##
    # Validate {#generate_html}
    # @return [true, false] if valid
    # @raise [ArgumentError] if not valid
    #
    def validate_generate_html(value)
      validate_in_array(value, [true, false])
    end

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

      # Should new data be automatically downloaded every 24 hrs?
      @get_daily@

      # Should a website be generated along with the JSON output?
      @generate_html@

      # The date that the data was last updated.
      # Should be in the form: 'YYYY-MM-DD'
      @updated_on@
      YAML
    end
  end
end
