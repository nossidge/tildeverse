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
    # Users authorised to run GET requests
    #
    # @!attribute [rw] authorised_users
    # @return [Array<String>] list of system user names
    # @raise [Error::AuthorisedUsersError] if not valid
    #
    attr_reader :authorised_users
    #
    # @param [Array<String>] value
    def authorised_users=(value)
      afterwards(:save) { @authorised_users = validate_authorised_users(value) }
    end

    ##
    # Method to use when GETting data from the Internet
    #
    # @!attribute [rw] update_type
    # @return [String] either 'scrape' or 'fetch'
    #
    attr_reader :update_type
    #
    # @param [String] value
    # @raise [Error::UpdateTypeError] if not valid
    def update_type=(value)
      afterwards(:save) { @update_type = validate_update_type(value) }
    end

    ##
    # Frequency to GET data from the Internet
    #
    # @!attribute [rw] update_frequency
    # @return [String] either 'always', 'day', 'week' or 'month'
    #
    attr_reader :update_frequency
    #
    # @param [String] value
    # @raise [Error::UpdateFrequencyError] if not valid
    def update_frequency=(value)
      afterwards(:save) { @update_frequency = validate_update_frequency(value) }
    end

    ##
    # @return [Date] date the data was last updated
    #
    attr_reader :updated_on

    ##
    # Load data from 'config.yml' if the file exists.
    # If it does not exist, create new file using default values.
    #
    # @param filepath [Pathname] path to the 'config.yml' file
    #
    def initialize(filepath = Files.config_yml)
      @filepath = filepath
      if @filepath.exist?
        data = YAML.safe_load(@filepath.read, [Date])
        @authorised_users = validate_authorised_users data['authorised_users']
        @update_type      = validate_update_type      data['update_type']
        @update_frequency = validate_update_frequency data['update_frequency']
        @updated_on       = validate_updated_on       data['updated_on']
      else
        apply_default_values
        save
      end
    end

    ##
    # Set {#updated_on} to today's date
    # @return [Date] today's date
    #
    def update
      afterwards(:save) { @updated_on = date_today }
    end

    ##
    # Save config settings to file
    #
    def save
      raise Error::DeniedByConfig unless authorised?

      str = yaml_template.dup

      # 'authorised_users' is an array, so use the nice YAML hyphen notation
      %w[
        authorised_users
      ].each do |var|
        val = send(var).map { |i| "\n  - #{i}" }.join
        str.sub!("@#{var}@", "#{var}:#{val}")
      end

      # These are scalar, so no problem
      %w[
        update_type
        update_frequency
        updated_on
      ].each do |var|
        str.sub!("@#{var}@", "#{var}:\n  #{send(var)}")
      end

      Files.save_text(str, @filepath)
    end

    ##
    # Consult the options to see if an update is needed today
    # @return [Boolean]
    #
    def update_required?
      now = date_today
      upd = updated_on

      case update_frequency
      when 'always'
        true

      when 'day'
        (now - upd).to_i.positive?

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
    # the return value of the block
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
        @updated_on       = dv[:updated_on]
      end
    end

    ##
    # Validate {#authorised_users}. Convert whatever input into a String array
    # @return [Array<String>] if valid
    # @raise [Error::AuthorisedUsersError] if not valid
    #
    def validate_authorised_users(value)
      [*value].map(&:to_s)
    rescue StandardError
      raise Error::AuthorisedUsersError
    end

    ##
    # Validate {#update_type}
    # @return [String] if valid
    # @raise [Error::UpdateTypeError] if not valid
    #
    def validate_update_type(input)
      input.tap do |value|
        valid = %w[scrape fetch]
        error = Error::UpdateTypeError
        raise error unless valid.include?(value)
      end
    end

    ##
    # Validate {#update_frequency}
    # @return [String] if valid
    # @raise [Error::UpdateFrequencyError] if not valid
    #
    def validate_update_frequency(input)
      input.tap do |value|
        valid = %w[always day week month]
        error = Error::UpdateFrequencyError
        raise error unless valid.include?(value)
      end
    end

    ##
    # Validate {#updated_on}
    # @return [Date] if valid
    # @raise [Error::UpdatedOnError] if not valid
    #
    def validate_updated_on(input)
      return input if input.respond_to?(:to_date)
      yyyy, mm, dd = input.to_s.split('-').map(&:to_i)
      Date.new(yyyy, mm, dd)
    rescue StandardError
      raise Error::UpdatedOnError
    end

    ##
    # Template for the YAML output.
    # We cannot use 'to_yaml' as it does not preserve comments.
    # @return [String]
    #
    def yaml_template
      # rubocop:disable Layout/IndentHeredoc
      <<~YAML
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

      # The date that the data was last updated. This is updated automatically,
      #   and will be overwritten on the next GET request.
      # Should be in the form: 'YYYY-MM-DD'
      @updated_on@
      YAML
      # rubocop:enable Layout/IndentHeredoc
    end
  end
end
