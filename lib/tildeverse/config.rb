#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'
require 'yaml'

module Tildeverse
  ##
  # Config information, including date of most recent update.
  # Reads from file 'config/config.yml'.
  #
  class Config
    ##
    # @return [Pathname] path to the 'config.yml' file
    #
    attr_reader :filepath

    ##
    # Users authorised to run GET requests.
    # @return [Array<String>] list of system user names.
    #
    attr_reader :authorised_users

    ##
    # Method to use when GETting data from the Internet.
    # @return [String] either 'scrape' or 'fetch'
    #
    attr_reader :update_type

    ##
    # Frequency to GET data from the Internet.
    # @return [String] either 'always', 'day', 'week' or 'month'
    #
    attr_reader :update_frequency

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
    # @param [Pathname] filepath Path to the 'config.yml' file
    #
    def initialize(filepath = Files.config_yml)
      @filepath = filepath
      if @filepath.exist?
        data = YAML.safe_load(@filepath.read, [Date])
        @authorised_users = validate_authorised_users data['authorised_users']
        @update_type      = validate_update_type      data['update_type']
        @update_frequency = validate_update_frequency data['update_frequency']
        @generate_html    = validate_generate_html    data['generate_html']
        @updated_on       = data['updated_on']
      else
        apply_default_values
        save
      end
    end

    ##
    # @param [Array<String>] value
    # @return [Array<String>] the input value
    # @raise [ArgumentError] if not valid
    #
    def authorised_users=(value)
      afterwards(:save) { @authorised_users = validate_authorised_users(value) }
    end

    ##
    # @param [String] value
    # @return [String] the input value
    # @raise [ArgumentError] if not valid
    #
    def update_type=(value)
      afterwards(:save) { @update_type = validate_update_type(value) }
    end

    ##
    # @param [String] value
    # @return [String] the input value
    # @raise [ArgumentError] if not valid
    #
    def update_frequency=(value)
      afterwards(:save) { @update_frequency = validate_update_frequency(value) }
    end

    ##
    # @param [true, false] value
    # @return [true, false] the input value
    # @raise [ArgumentError] if not valid
    #
    def generate_html=(value)
      afterwards(:save) { @generate_html = validate_generate_html(value) }
    end

    ##
    # Set {#updated_on} to today's date
    # @return [Date] today's date
    #
    def update
      afterwards(:save) { @updated_on = date_today }
    end

    ##
    # Save config settings to file.
    #
    def save
      str = yaml_template

      # 'authorised_users' is an array, so use the nice YAML hyphen notation.
      %w[
        authorised_users
      ].each do |var|
        val = send(var).map { |i| "\n  - #{i}" }.join
        str.sub!("@#{var}@", "#{var}:#{val}")
      end

      # These are scalar, so no problem.
      %w[
        update_type
        update_frequency
        generate_html
        updated_on
      ].each do |var|
        str.sub!("@#{var}@", "#{var}:\n  #{send(var)}")
      end

      Files.save_text(str, @filepath)
    end

    ##
    # Consult the options to see if an update is needed today
    # @return [true, false]
    #
    def update_required?
      now = date_today
      upd = updated_on

      case update_frequency
      when 'always'
        true

      when 'day'
        (now - upd).to_i > 0

      when 'week'
        mon_date = now - now.cwday + 1
        sun_date = mon_date + 6
        week_range = (mon_date..sun_date)
        !week_range.include?(upd)

      when 'month'
        return false if now < upd
        now.year != upd.year || now.month != upd.month

      else
        raise ArgumentError, 'Value must be one of: always, day, week, month'
      end
    end

    ##
    # Is the logged-in user authorised to alter data?
    # @return [Boolean]
    #
    def authorised?(current_user = Etc.getlogin)
      return true if authorised_users.empty?
      authorised_users.include?(current_user)
    end

    private

    ##
    # Yield to a block, run a method, and return
    # the return value of the block.
    #
    def afterwards(method_name)
      yield.tap do
        method(method_name).call
      end
    end

    ##
    # Today's date. Separated out to a method for ease of testing
    # @return [Date]
    #
    def date_today
      Date.today
    end

    ##
    # Declare the default value for each config variable
    # @return [Hash]
    #
    def default_values
      {
        authorised_users: [],
        update_type:      'fetch',
        update_frequency: 'day',
        generate_html:    false,
        updated_on:       Date.new(1970, 1, 1)
      }
    end

    ##
    # Set the default value to each instance variable
    #
    def apply_default_values
      default_values.tap do |dv|
        @authorised_users = dv[:authorised_users]
        @update_type      = dv[:update_type]
        @update_frequency = dv[:update_frequency]
        @generate_html    = dv[:generate_html]
        @updated_on       = dv[:updated_on]
      end
    end

    ##
    # Validate {#authorised_users}. Convert whatever input into a String array
    # @return [Array<String>] if valid
    # @raise [ArgumentError] if not valid
    #
    def validate_authorised_users(value)
      [*value].map(&:to_s)
    rescue StandardError
      raise ArgumentError, 'Value must be an array of Strings'
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
    # Validate {#update_type}
    # @return [String] if valid
    # @raise [ArgumentError] if not valid
    #
    def validate_update_type(value)
      validate_in_array(value, %w[scrape fetch])
    end

    ##
    # Validate {#update_frequency}
    # @return [String] if valid
    # @raise [ArgumentError] if not valid
    #
    def validate_update_frequency(value)
      validate_in_array(value, %w[always day week month])
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
    # Template for the YAML output.
    # We cannot use 'to_yaml' as it does not preserve comments.
    # @return [String]
    #
    def yaml_template
      <<-YAML.gsub(/^ {6}/, '')
      # Array of users that are authorised to run scrape or fetch requests.
      # This is not a substitute for system administration; it will not prevent
      #   data loss by malicious actors. It is intended to protect against
      #   well-intentioned users that may not be aware of the full effects of
      #   overwriting the data.
      # An empty array indicates that any user can update the data.
      @authorised_users@

      # Determines how data is gathered from the remote servers.
      # Can be either 'scrape' or 'fetch'.
      # 'scrape' => Return live results by scraping each site in the Tildeverse.
      # 'fetch'  => (RECOMMENDED) Return daily pre-scraped results from the file
      #             at tilde.town. This is run hourly, so the results will
      #             likely be more accurate than manual scraping.
      @update_type@

      # Frequency to GET the live results from the remote servers.
      # 'always' => (NOT RECOMMENDED) Always GET, each time the program is run.
      # 'day'    => GET daily.
      # 'week'   => GET weekly, on Monday.
      # 'month'  => GET monthly, on the 1st.
      @update_frequency@

      # Should a website be generated along with the TXT and JSON output?
      @generate_html@

      # The date that the data was last updated. This is updated automatically,
      #   and will be overwritten on the next GET request.
      # Should be in the form: 'YYYY-MM-DD'
      @updated_on@
      YAML
    end
  end
end
