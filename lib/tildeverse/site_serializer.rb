#!/usr/bin/env ruby

module Tildeverse
  ##
  # Methods for serialising a site full of users
  #
  # To be included by the {Site} class
  #
  class SiteSerializer
    ##
    # @param [Site] site Site object to serialise
    #
    def initialize(site)
      @site = site
    end

    ##
    # Serialize the data for writing to {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_output
      serialize(@site.users.select(&:online?))
    end

    private

    ##
    # Serialize the data
    #
    # @param [Array<User>] users_array list of users to display
    #
    def serialize(users_array)
      {}.tap do |h|
        h[:url_root]        = @site.root
        h[:url_list]        = @site.resource
        h[:url_format_user] = @site.url_format_user
        h[:online]          = @site.online?
        h[:user_count]      = users_array.count
        h[:users]           = serialize_users(users_array)
      end
    end

    ##
    # @param [Array<User>] users_array list of users to display
    # @return [Hash]
    #
    def serialize_users(users_array)
      {}.tap do |h|
        users_array.each do |user|
          h[user.name] = user.serialize.serialize_output
        end
      end
    end
  end
end
