#!/usr/bin/env ruby

module Tildeverse
  ##
  # Methods for serialising an individual user
  #
  # To be included by the {User} class
  #
  module UserSerializer
    ##
    # @return [String] string representation of the contents of the instance
    #
    def to_s
      UserSerializerClass.new(self).to_s
    end

    ##
    # Serialize the data for writing to {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_output
      UserSerializerClass.new(self).serialize_output
    end

    ##
    # Serialize the data as an array for later WSV formatting.
    #
    # @return [Array<String>]
    #
    def serialize_to_txt_array
      UserSerializerClass.new(self).serialize_to_txt_array
    end
  end
end
