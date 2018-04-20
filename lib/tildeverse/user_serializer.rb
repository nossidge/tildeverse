#!/usr/bin/env ruby

module Tildeverse
  ##
  # Methods for serialising an individual user
  #
  # To be included by the {User} class
  #
  module UserSerializer
    ##
    # Serialize the data for writing to {Files#input_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_input
      {}.tap do |h|
        h[:tagged] = tagged if tagged
        h[:tags]   = tags   if tags
      end
    end

    ##
    # Serialize the data for writing to {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_output
      {}.tap do |h|
        h[:tagged] = tagged if tagged
        h[:tags]   = tags   if tags
        h[:time]   = modified_date
      end
    end
  end
end
