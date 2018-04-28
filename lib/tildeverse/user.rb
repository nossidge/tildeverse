#!/usr/bin/env ruby

module Tildeverse
  ##
  # Class to store information for a particular user.
  #
  # Relation model is:
  #   Data
  #   └── Site       (has many)
  #       └── User   (has many)
  #
  class User
    include UserSerializer

    ##
    # @return [Site] The site the user belongs to.
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
    # @param [Site] site The site the user belongs to.
    # @param [String] name The name of the user.
    # @param [String] date_online The date the user first came online.
    # @param [String] date_offline The date the user went offline.
    # @param [String] date_modified The date the user site was last modified.
    # @param [String] date_tagged The date the tags were last updated.
    # @param [Array<String>] tags A list of usersite tags for the user.
    #
    def initialize(
      site: nil,
      name: nil,
      date_online: '-',
      date_offline: '-',
      date_modified: '-',
      date_tagged: '-',
      tags: []
    )
      raise NoMethodError unless site && name
      @site          = site
      @name          = name
      @date_online   = date_online
      @date_offline  = date_offline
      @date_modified = date_modified
      @tagged        = date_tagged
      @tags          = tags
      @online        = false
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
    # Use {Site#url_format_user} to map the user to their homepage URL
    #
    # @return [String] user's homepage
    # @example
    #   tilde_town = Site.new('tilde.town')
    #   tilde_town.user('nossidge').url
    #   # => 'https://tilde.town/~nossidge/'
    #
    def url
      site.user_page(name)
    end

    ##
    # Use {Site#name} to map the user to their email address
    #
    # @return [String] user's email address
    # @example
    #   tilde_town = Site.new('tilde.town')
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
  end
end
