#!/usr/bin/env ruby

module Tildeverse
  ##
  # Class for serialising a Site full of Users
  #
  class SiteSerializer
    attr_reader :site

    ##
    # @param [Site] site Site object to serialise
    #
    def initialize(site)
      @site = site
    end

    ##
    # @param [Array<User>] users_array list of users to include in the output
    # @return [Hash]
    #
    def to_h(users_array = site.users_online)
      {
        url_root:         site.root,
        url_list:         site.resource,
        url_format_user:  site.url_format_user,
        online:           site.online?,
        user_count:       users_array.count,
        users:            serialize_users(users_array)
      }
    end

    ##
    # Serialize the data for writing to {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def for_tildeverse_json
      to_h
    end

    private

    ##
    # @param [Array<User>] users_array list of users to display
    # @return [Hash]
    #
    def serialize_users(users_array)
      {}.tap do |h|
        users_array.each do |user|
          h[user.name] = user.serialize.for_tildeverse_json
        end
      end
    end
  end
end
