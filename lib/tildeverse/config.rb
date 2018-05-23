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
    def initialize
      if filepath.exist?
        data = YAML.safe_load(filepath.read, [Date])
        @update_type      = validate_update_type      data['update_type']
        @update_frequency = validate_update_frequency data['update_frequency']
        @generate_html    = validate_generate_html    data['generate_html']
        @updated_on       = data['updated_on']
      else
        @update_type      = 'fetch'
        @update_frequency = 'day'
        @generate_html    = false
        @updated_on       = Date.new(1970, 1, 1)
      end
      save
    end

    ##
    # @param [String] value
    # @return [String] the input value
    # @raise [ArgumentError] if not valid
    #
    def update_type=(value)
      with(:save) { @update_type = validate_update_type(value) }
    end

    ##
    # @param [true, false] value
    # @return [true, false] the input value
    # @raise [ArgumentError] if not valid
    #
    def update_frequency=(value)
      with(:save) { @update_frequency = validate_update_frequency(value) }
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
      %w[update_type update_frequency generate_html updated_on].each do |var|
        str.sub!("@#{var}@", "#{var}:\n  #{send(var)}")
      end
      Files.save_text(str, filepath)
    end

    ##
    # Consult the options to see if an update is needed today
    # @return [true, false]
    #
    def update_required?
      now = Date.today
      upd = updated_on

      case update_frequency
      when 'always'
        true

      when 'day'
        (now - upd).to_i != 0

      when 'week'
        mon_date = now - now.cwday + 1
        sun_date = mon_date + 6
        week_range = (mon_date..sun_date)
        !week_range.include?(upd)

      when 'month'
        now.year != upd.year || now.month != upd.month
      end
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
    # File path of the config YAML. Creates directory if not yet existing.
    #
    def filepath
      dir_config = Files.dir_root + 'config'
      Files.makedirs(dir_config) unless dir_config.exist?
      dir_config + 'config.yml'
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
      @update_type@

      # Frequency to GET the live results from the remote servers.
      # 'always' => (NOT RECOMMENDED) Always GET, each time the program is run.
      # 'day'    => GET daily.
      # 'week'   => GET weekly, on Monday.
      # 'month'  => GET monthly, on the 1st.
      @update_frequency@

      # Should a website be generated along with the JSON output?
      @generate_html@

      # The date that the data was last updated.
      # Should be in the form: 'YYYY-MM-DD'
      @updated_on@
      YAML
    end
  end
end
