#!/usr/bin/env ruby

module Tildeverse
  ##
  # Methods for serialising a site full of users
  #
  # To be included by the {Site} class
  #
  module SiteSerializer
    ##
    # Serialize the data for writing to {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_output
      SiteSerializerClass.new(self).serialize_output
    end
  end
end
