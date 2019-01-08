#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  ##
  # Class for serialising a {Site} full of {User} objects
  #
  class SiteSerializer
    ##
    # @return [Site] Site object to serialise
    #
    attr_reader :site

    ##
    # Creates a new {SiteSerializer} that will serialise one {Site} object
    #
    # @param site [Site] Site object to serialise
    #
    def initialize(site)
      @site = site
    end

    ##
    # Serialize {#site} information as a string
    #
    # @return [String] string representation of the contents of {#site}
    #
    def to_s
      {
        name:             site.name,
        root:             site.uri.root,
        list:             site.uri.list,
        homepage_format:  site.uri.homepage_format,
        online?:          site.online?,
        users:            site.users.count,
        users_online:     site.users_online.count
      }.to_s
    end

    ##
    # Serialize {#site} information as a hash
    #
    # @param users_array [Array<User>] list of users to include in the output
    # @return [Hash] {#site} information in a hash format
    #
    def to_h(users_array = site.users_online)
      {
        url_root:         site.uri.root,
        url_list:         site.uri.list,
        url_format_user:  site.uri.homepage_format,
        online:           site.online?,
        user_count:       users_array.count,
        users:            serialize_users(users_array)
      }
    end

    ##
    # Serialize {#site} for writing to {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def for_tildeverse_json
      to_h
    end

    private

    ##
    # @param users_array [Array<User>] list of users to display
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
