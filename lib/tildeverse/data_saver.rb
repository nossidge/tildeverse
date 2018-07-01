#!/usr/bin/env ruby

module Tildeverse
  ##
  # Class for saving a Data class to file
  #
  class DataSaver
    attr_reader :data

    ##
    # @param [Data] data Data object to serialise
    #
    def initialize(data)
      @data = data
    end

    ##
    # Serialise data to files 'tildeverse.txt' and 'tildeverse.json'
    #
    def save
      wsv = data.serialize.for_tildeverse_txt
      file = Files.dir_input + 'tildeverse.txt'
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
      #
      # Write 'users.json' for backwards compatibility
      # Used by http://tilde.town/~insom/modified.html
      json = data.serialize.for_users_json
      file = Files.output_json_users
      Files.save_json(json, file)

      # Copy all static files to the output directory
      Files.files_to_copy.each do |f|
        from = Files.dir_input  + f
        to   = Files.dir_output + f
        FileUtils.cp(from, to)
      end
    end

    ##
    # Run {#save}
    #
    # Run {#save_website} if the config option
    # {Tildeverse::Config#generate_html} is true
    #
    def save_with_config
      save
      save_website if data.config.generate_html?
    end
  end
end
