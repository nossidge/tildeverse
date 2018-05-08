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
      {
        site:           @site.name,
        name:           @name,
        date_online:    @date_online,
        date_offline:   @date_offline,
        date_modified:  @date_modified,
        date_tagged:    @date_tagged,
        tags:           @tags.join(','),
        online:         online?
      }.to_s
    end

    ##
    # Serialize the data for writing to {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_output
      {}.tap do |h|
        h[:tagged] = date_tagged if date_tagged
        h[:tags]   = tags        if tags
        h[:time]   = date_modified
      end
    end

    ##
    # Serialize the data as an array for later WSV formatting.
    #
    # @return [Array<String>]
    #
    def serialize_to_txt_array
      [
        @site.name,
        @name,
        @date_online,
        @date_offline,
        @date_modified,
        @date_tagged,
        @tags.empty? ? '-' : @tags.join(',')
      ]
    end
  end
end
