#!/usr/bin/env ruby

module Tildeverse
  ##
  # Class to store information for a particular user.
  #
  # Relation model is:
  #   Data
  #   └── TildeSite  (has many)
  #       └── User   (has many)
  #
  class User
    ##
    # @return [TildeSite] The site the user belongs to.
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
    # @return [Array<String>] A list of usersite tags for the user.
    #
    attr_reader :tags

    ##
    # @param [TildeSite] site The site the user belongs to.
    # @param [String] name The name of the user.
    # @param [String] tagged The date the tags were last updated.
    # @param [Array<String>] tags A list of usersite tags for the user.
    #
    def initialize(site, name, tagged = nil, tags = [])
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
    # Use {TildeSite#url_format_user} to map the user to their homepage URL
    #
    # @return [String] user's homepage
    # @example
    #   tilde_town = TildeSite.new('tilde.town')
    #   tilde_town.user('nossidge').url
    #   # => 'https://tilde.town/~nossidge/'
    #
    def url
      site.user_page(name)
    end

    ##
    # Use {TildeSite#name} to map the user to their email address
    #
    # @return [String] user's email address
    # @example
    #   tilde_town = TildeSite.new('tilde.town')
    #   tilde_town.user('nossidge').email
    #   # => 'nossidge@tilde.town'
    # @note
    #   On most Tilde servers, this is valid for local email only
    #
    def email
      site.user_email(name)
    end

    ##
    # Return the modified date of the user page
    #
    # @return [String] string representation of the datetime
    #
    def modified_date
      ModifiedDates.instance.for_user(site.name, name) || '-'
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
