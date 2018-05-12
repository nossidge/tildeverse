#!/usr/bin/env ruby

module Tildeverse
  ##
  # TODO: Document this.
  #
  class Config
    ##
    #
    #
    attr_reader :get_type

    ##
    #
    #
    attr_reader :last_update

    ##
    # Load data from 'config.yml' if the file exists.
    # If it does not exist, create new file using default values.
    #
    def initialize
      if filepath.exist?
        data = YAML.safe_load(filepath.read, [Date])
        @get_type    = data['get_type']
        @last_update = data['last_update']
      else
        @get_type    = 'fetch'
        @last_update = Date.new(1970, 1, 1)
        save
      end
    end

    ##
    #
    #
    def get_type=(input)
      unless types_of_get.include?(input)
        raise ArgumentError, "Value must be one of: #{types_of_get.join(', ')}"
      end
      @get_type = input
      save
    end

    ##
    #
    #
    def update
      @last_update = Date.today
      save
    end

    ##
    #
    #
    def save
      str = yaml_template
      %w[get_type last_update].each do |var|
        str.sub!("@#{var}@", "#{var}:\n  #{send(var)}")
      end
      Files.save_text(str, filepath)
    end

    private

    ##
    #
    #
    def filepath
      dir_config = Files.dir_root + 'config'
      Files.makedirs(dir_config) unless dir_config.exist?
      dir_config + 'config.yml'
    end

    ##
    #
    #
    def types_of_get
      %w[scrape fetch]
    end

    ##
    #
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
      @last_update@
      YAML
    end
  end
end
