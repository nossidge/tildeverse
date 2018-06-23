#!/usr/bin/env ruby

module Tildeverse
  ##
  # Methods for serialising data at a high level
  #
  # To be included by the {Data} class
  #
  class DataSerializer
    ##
    # @param [Data] data Data object to serialise
    #
    def initialize(data)
      @data = data
    end

    ##
    # Serialise an array of users to a hash, with site name as the key,
    # then user name, then user details
    #
    # @param [Array<User>] users
    # @return [Hash{String => Hash{String => User}}]
    #
    def serialize_users(users)
      {}.tap do |site_hash|
        users.each do |user|
          serializer = UserSerializer.new(user)
          site_hash[user.site.name] ||= {}
          site_hash[user.site.name][user.name] = serializer.serialize_output
        end
      end
    end

    ##
    # Serialise an array of sites to a hash, with site name as the key,
    # then user name, then user details
    #
    # @param [Array<Site>] sites
    # @return [Hash{String => Site#serialize_output}]
    #
    def serialize_sites(sites)
      {}.tap do |site_hash|
        [*sites].each do |site|
          serializer = SiteSerializer.new(site)
          site_hash[site.name] = serializer.serialize_output
        end
      end
    end

    ##
    # Serialise all sites in the sites_hash
    #
    # @return [Hash{String => Site#serialize_output}]
    #
    def serialize_all_sites
      serialize_sites(@data.sites)
    end

    ##
    # Serialize data in the format of {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_tildeverse_json
      {
        metadata: {
          url: 'http://tilde.town/~nossidge/tildeverse/',
          date_human:    Time.now.strftime('%Y/%m/%d %H:%M'),
          date_unix:     Time.now.to_i,
          date_timezone: Time.now.getlocal.zone
        },
        sites: serialize_all_sites
      }
    end

    ##
    # Serialize data in the format of {Files#output_json_users}
    #
    # @return [Hash]
    #
    def serialize_users_json
      {}.tap do |h1|
        @data.sites.each do |site|
          h1[site.root] = {}.tap do |h2|
            site.users.map(&:name).each do |user|
              h2[user] = site.user_page(user)
            end
          end
        end
      end
    end

    ##
    # Serialize all users as an array of WSV formatted strings,
    # including a header row
    #
    # @return [Array<String>]
    #
    def serialize_tildeverse_txt
      header = %w[
        SITE_NAME USER_NAME DATE_ONLINE DATE_OFFLINE
        DATE_MODIFIED DATE_TAGGED TAGS
      ]
      all_users = @data.sites.map!(&:users).flatten!
      user_table = [header] + all_users.map! do |user|
        UserSerializer.new(user).serialize_to_txt_array
      end
      WSV.new(user_table).to_wsv
    end
  end
end
