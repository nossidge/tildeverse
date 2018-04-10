#!/usr/bin/env ruby

module Tildeverse
  ##
  #
  #
  class User

    ##
    # @return [String] The name of the site.
    #
    attr_reader :site

    ##
    # @return [String] The name of the user.
    #
    attr_reader :name

    ##
    # @return [String, nil] The date the tags were last updated.
    #
    attr_reader :tagged

    ##
    # @return [Array<String>, nil] A list of usersite tags for the user.
    #
    attr_reader :tags

    ##
    # @param [String] site The name of the site.
    # @param [String] name The name of the user.
    # @param [String] tagged The date the tags were last updated.
    # @param [Array<String>] tags A list of usersite tags for the user.
    #
    def initialize(site, name, tagged = nil, tags = nil)
      @site   = site
      @name   = name
      @tagged = tagged
      @tags   = tags
      @online = false
    end

    ##
    # Set a boolean for the {#online?} method
    #
    # @param [Boolean] boolean whether or not the user is online
    #
    def online=(boolean)
      raise ArgumentError unless [true, false].include?(boolean)
      @online = boolean
    end

    ##
    # @return [Boolean] whether or not the user is online
    #
    def online?
      @online
    end

    ##
    # Return the modified date of the user page
    #
    # @return [String] string representation of the datetime
    #
    def modified_date
      @@modified_dates ||= Tildeverse::ModifiedDates.new
      @@modified_dates.for_user(site, name) || '-'
    end

    ##
    # Serialize the data for writing to {Files#input_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_input
      {}.tap do |hash|
        hash[:tagged] = tagged if tagged
        hash[:tags] = tags if tags
      end
    end

    ##
    # Serialize the data for writing to {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_output
      {}.tap do |hash|
        hash[:tagged] = tagged if tagged
        hash[:tags] = tags if tagged
        hash[:time] = modified_date
      end
    end
  end
end
