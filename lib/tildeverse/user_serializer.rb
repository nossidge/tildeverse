#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  ##
  # Class for serialising an individual {User}
  #
  class UserSerializer
    ##
    # @return [User] User object to serialise
    #
    attr_reader :user

    ##
    # Creates a new {UserSerializer} that will serialise one {User} object
    #
    # @param user [User] User object to serialise
    #
    def initialize(user)
      @user = user
    end

    ##
    # Serialize {#user} information as a string
    #
    # @return [String] string representation of {#user} information
    #
    def to_s
      {
        site:          user.site.name,
        name:          user.name,
        date_online:   user.date_online.to_s,
        date_offline:  user.date_offline.to_s,
        date_modified: user.date_modified.to_s,
        date_tagged:   user.date_tagged.to_s,
        tags:          user.tags.to_s,
        online:        user.online?
      }.to_s
    end

    ##
    # Serialize {#user} information as an array for later WSV formatting
    #
    # @return [Array<String>]
    #
    def to_a
      [
        user.site.name,
        user.name,
        user.date_online,
        user.date_offline,
        user.date_modified,
        user.date_tagged,
        user.tags.to_s
      ]
    end

    ##
    # Serialize {#user} for writing to {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def for_tildeverse_json
      {}.tap do |h|
        h[:date_modified] = user.date_modified
        h[:date_tagged]   = user.date_tagged if user.date_tagged
        h[:tags]          = user.tags        if user.tags
      end
    end
  end
end
