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

      # Write 'users.json' for backwards compatibility
      # Used by http://tilde.town/~insom/modified.html
      json = data.serialize.for_users_json
      file = Files.output_json_users
      Files.save_json(json, file)

      data.config.update
    end
  end
end
