#!/usr/bin/env ruby
# frozen_string_literal: true

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
    # @return [Array<String>] master array of valid initialize options
    #
    VALID_OPTIONS = %i[
      date_online date_offline date_modified date_tagged tags
    ].freeze

    ##
    # @return [Site] the site the user belongs to
    #
    attr_reader :site

    ##
    # @return [String] the name of the user
    #
    attr_reader :name

    ##
    # @return [TildeDate] the date the user first came online
    #
    attr_reader :date_online

    ##
    # @!attribute [rw] date_offline
    # @return [TildeDate] the date the user went offline
    #
    attr_reader :date_offline
    #
    # @param [String, Date, TildeDate] value
    def date_offline=(value)
      @date_offline = TildeDate.new(value)
    end

    ##
    # @!attribute [rw] date_modified
    # @return [TildeDate] the date the user's homepage was last modified
    #
    attr_reader :date_modified
    #
    # @param [String, Date, TildeDate] value
    #   the date the user's homepage was last modified
    def date_modified=(value)
      @date_modified = TildeDate.new(value)
    end

    ##
    # The date the tags were last updated.
    # This is updated to today's date whenever {tags=} is called
    #
    # @return [TildeDate] the date the tags were last updated
    #
    attr_reader :date_tagged

    ##
    # Settting this attribute also updates {date_tagged} to today's date
    #
    # @!attribute [rw] tags
    # @return [TagArray] a list of usersite tags for the user
    # @raise [Error::InvalidTags] if any tag is not valid
    #
    attr_reader :tags
    #
    # @param tags [Array<String>, TagArray] the array of tags
    def tags=(tags)
      @tags = TagArray.new(tags)
      @date_tagged = TildeDate.new(Date.today)
    end

    ##
    # Returns a new instance of User
    #
    # @param site [Site] the site the user belongs to
    # @param name [String] the name of the user
    # @option options [String, Date, TildeDate] :date_online
    #   the date the user first came online
    # @option options [String, Date, TildeDate] :date_offline
    #   the date the user went offline
    # @option options [String, Date, TildeDate] :date_modified
    #   the date the user site was last modified
    # @option options [String, Date, TildeDate] :date_tagged
    #   the date the tags were last updated
    # @option options [Array<String>, TagArray] :tags
    #   a list of usersite tags for the user
    #
    def initialize(site:, name:, **options)
      dodgy_args = options.keys - VALID_OPTIONS
      raise ArgumentError, dodgy_args unless dodgy_args.empty?

      @site          = site
      @name          = name
      @date_online   = TildeDate.new options[:date_online]
      @date_offline  = TildeDate.new options[:date_offline]
      @date_modified = TildeDate.new options[:date_modified]
      @date_tagged   = TildeDate.new options[:date_tagged]
      @tags          = TagArray.new(options[:tags], validation: false)
    end

    ##
    # @return [UserSerializer]
    #   serializer object, passing self to {UserSerializer#initialize}
    #
    def serialize
      UserSerializer.new(self)
    end

    ##
    # @return [String] string representation of the object
    #
    def to_s
      serialize.to_s
    end

    ##
    # This is based on the values of {date_online} and {date_offline}.
    # If {date_online} is not its default value, and {date_offline} is
    # its default value, then the user can be said to be online
    #
    # @return [Boolean] whether or not the user is online
    #
    def online?
      is_online      = date_online  != TildeDate::EPOCH
      is_not_offline = date_offline == TildeDate::EPOCH
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

    ##
    # Use HTTP to query the user's homepage and return the 'last-modified'
    # header datetime. If a valid datetime is returned from the header,
    # The {#date_modified} attribute will be updated.
    #
    # @return [DateTime] last modified date
    # @return [nil] if header value is not returned
    #
    def date_modified!
      uri = URI URI::encode(homepage)
      res = Net::HTTP.get_response(uri)
      last_modified = res['last-modified']
      return nil unless last_modified
      self.date_modified = DateTime.parse(last_modified)
    end
  end
end
