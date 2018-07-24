#!/usr/bin/env ruby

module Tildeverse
  ##
  # Class to store information for a particular user
  #
  # Relation model is:
  #   Data
  #   └── Site       (has many)
  #       └── User   (has many)
  #
  class User
    ##
    # @return [Site] the site the user belongs to
    #
    attr_reader :site

    ##
    # @return [String] the name of the user
    #
    attr_reader :name

    ##
    # @return [String] the date the user first came online
    #
    attr_reader :date_online

    ##
    # @return [String] the date the user first went offline
    #
    attr_reader :date_offline

    ##
    # @return [String] the date the user's homepage was last modified
    #
    attr_reader :date_modified

    ##
    # The date the tags were last updated.
    # This is updated to today's date whenever {tags=} is called
    #
    # @return [String] the date the tags were last updated
    #
    attr_reader :date_tagged

    ##
    # @return [Array<String>] a list of usersite tags for the user
    #
    attr_reader :tags

    ##
    # Returns a new instance of User
    #
    # @param [Site] site the site the user belongs to.
    # @param [String] name the name of the user.
    # @param [String] date_online the date the user first came online.
    # @param [String] date_offline the date the user went offline.
    # @param [String] date_modified the date the user site was last modified.
    # @param [String] date_tagged the date the tags were last updated.
    # @param [Array<String>] tags a list of usersite tags for the user.
    #
    def initialize(
      site:,
      name:,
      date_online: default_date_online,
      date_offline: default_date_offline,
      date_modified: default_date_modified,
      date_tagged: default_date_tagged,
      tags: default_tags
    )
      @site          = site
      @name          = name
      @date_online   = date_online
      @date_offline  = date_offline
      @date_modified = date_modified
      @date_tagged   = date_tagged
      @tags          = tags
    end

    ##
    # @return [UserSerializer]
    #   serializer object, passing self to {UserSerializer#initialize}
    #
    def serialize
      UserSerializer.new(self)
    end

    ##
    # Set the {date_offline} attribute
    #
    # @param [String] value the date the user first went offline
    # @return [String] the date the user first went offline
    #
    def date_offline=(value)
      @date_offline = value
    end

    ##
    # Set the {date_modified} attribute
    #
    # @param [String] value the date the user's homepage was last modified
    # @return [String] the date the user's homepage was last modified
    #
    def date_modified=(value)
      @date_modified = value
    end

    ##
    # Set the {tags} attribute.
    # Also updates {#date_tagged} to today's date
    #
    # @param [Array<String>] tags the array of tags
    # @return [Array<String>] the array of tags
    #
    def tags=(tags)
      @date_tagged = Date.today.to_s
      @tags = [*tags].flatten.sort.uniq
    end

    ##
    # This is based on the values of {date_online} and {date_offline}.
    # If {date_online} is not its default value, and {date_offline} is
    # its default value, then the user can be said to be online
    #
    # @return [Boolean] whether or not the user is online
    #
    def online?
      is_online      = @date_online  != default_date_online
      is_not_offline = @date_offline == default_date_offline
      is_online && is_not_offline
    end

    ##
    # Call {TildeSiteURI#homepage} with {#name} as the parameter
    #
    # @return [String] user's homepage URL
    #
    def homepage
      site.uri.homepage(name)
    end

    ##
    # Call {TildeSiteURI#email} with {#name} as the parameter
    #
    # @return [String] user's email address
    #
    def email
      site.uri.email(name)
    end

    private

    def default_date_online
      '-'
    end

    def default_date_offline
      '-'
    end

    def default_date_modified
      '-'
    end

    def default_date_tagged
      '-'
    end

    def default_tags
      []
    end
  end
end
