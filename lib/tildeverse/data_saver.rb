#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  ##
  # Class for saving the contents of a Data object to file
  #
  class DataSaver
    ##
    # @return [Data] Data object to save to file
    #
    attr_reader :data

    ##
    # @param [Data] data Data object to save to file
    #
    def initialize(data)
      @data = data
    end

    ##
    # Serialise data to files 'tildeverse.txt' and 'tildeverse.json'
    #
    def save
      raise Error::DeniedByConfig unless data.config.authorised?

      wsv = data.serialize.for_tildeverse_txt
      file = Files.input_txt_tildeverse
      Files.save_array(wsv, file)

      file = Files.output_txt_tildeverse
      Files.save_array(wsv, file)

      json = data.serialize.for_tildeverse_json
      file = Files.output_json_tildeverse
      Files.save_json(json, file)

      data.config.update
    end

    ##
    # Save HTML and JS files and generate data for the website output
    #
    def save_website
      raise Error::DeniedByConfig unless data.config.authorised?

      # Write 'users.json' for backwards compatibility
      # Used by http://tilde.town/~insom/modified.html
      json = data.serialize.for_users_json
      file = Files.output_json_users
      Files.save_json(json, file)

      # Copy all static files from /input/ to /output/
      from = Files.dir_input.to_s + '/.'
      to   = Files.dir_output
      FileUtils.cp_r(from, to)
    end

    ##
    # Run {DataSaver#save}
    #
    # Run {DataSaver#save_website} if the config option
    # {Tildeverse::Config#generate_html} is true
    #
    def save_with_config
      raise Error::DeniedByConfig unless data.config.authorised?

      save
      save_website if data.config.generate_html?
    end
  end
end
