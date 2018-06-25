#!/usr/bin/env ruby

module Tildeverse
  ##
  # Class for serialising an individual User
  #
  class UserSerializer
    attr_reader :user

    ##
    # @param [User] user User object to serialise
    #
    def initialize(user)
      @user = user
    end

    ##
    # @return [String] string representation of the contents of the instance
    #
    def to_s
      {
        site:          user.site.name,
        name:          user.name,
        date_online:   user.date_online,
        date_offline:  user.date_offline,
        date_modified: user.date_modified,
        date_tagged:   user.date_tagged,
        tags:          user.tags.join(','),
        online:        user.online?
      }.to_s
    end

    ##
    # Serialize the data as an array for later WSV formatting.
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
        user.tags.empty? ? '-' : user.tags.join(',')
      ]
    end

    ##
    # Serialize the data for writing to {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def for_tildeverse_json
      {}.tap do |h|
        h[:tagged] = user.date_tagged if user.date_tagged
        h[:tags]   = user.tags        if user.tags
        h[:time]   = user.date_modified
      end
    end
  end
end
