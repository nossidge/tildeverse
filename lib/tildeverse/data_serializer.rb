#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  ##
  # Methods for serialising data at a high level
  #
  class DataSerializer
    attr_reader :data

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
    def users(users = data.users)
      {}.tap do |site_hash|
        users.each do |user|
          site_name = user.site.name
          site_hash[site_name] ||= {}
          site_hash[site_name][user.name] = user.serialize.for_tildeverse_json
        end
      end
    end

    ##
    # Serialise an array of sites to a hash, with site name as the key,
    # then user name, then user details
    #
    # @param [Array<Site>] sites
    # @return [Hash{String => SiteSerializer#for_tildeverse_json}]
    #
    def sites(sites = data.sites)
      {}.tap do |site_hash|
        [*sites].each do |site|
          site_hash[site.name] = site.serialize.for_tildeverse_json
        end
      end
    end

    ############################################################################

    ##
    # Serialize data in the format of {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def for_tildeverse_json
      {
        metadata: {
          url: 'http://tilde.town/~nossidge/tildeverse/',
          date_human:    Time.now.strftime('%Y/%m/%d %H:%M'),
          date_unix:     Time.now.to_i,
          date_timezone: Time.now.getlocal.zone
        },
        sites: sites(data.sites)
      }
    end

    ##
    # Serialize data in the format of {Files#output_json_users}
    #
    # @return [Hash]
    #
    def for_users_json
      {}.tap do |h1|
        data.sites.each do |site|
          h1[site.uri.root] = {}.tap do |h2|
            site.users.map(&:name).each do |user|
              h2[user] = site.uri.homepage(user)
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
    def for_tildeverse_txt
      header = %w[
        SITE_NAME USER_NAME DATE_ONLINE DATE_OFFLINE
        DATE_MODIFIED DATE_TAGGED TAGS
      ]
      all_users = data.sites.map!(&:users).flatten!
      user_table = [header] + all_users.map! do |user|
        user.serialize.to_a
      end
      WSV.new(user_table).to_wsv
    end

    ############################################################################

    ##
    # Serialise an array of users to a whitespace-delimited array of strings
    #
    # @param [Array<User>] users
    # @return [Array<String>] whitespace-delimited values
    #
    def users_as_wsv(users = data.users)
      header = %w[SITE NAME URL MODIFIED TAGGED TAGS]
      output = [header] + [*users].map do |user|
        [
          user.site.name,
          user.name,
          user.homepage,
          user.date_modified,
          user.date_tagged || '-',
          user.tags.empty? ? '-' : user.tags.join(',')
        ]
      end
      WSV.new(output).to_wsv
    end

    ##
    # Serialise an array of sites to a whitespace-delimited array of strings
    #
    # @param [Array<Site>] sites
    # @return [Array<String>] whitespace-delimited values
    #
    def sites_as_wsv(sites = data.sites)
      header = %w[NAME URL USERS]
      output = [header] + [*sites].map do |site|
        [
          site.name,
          site.uri.root,
          site.users.count
        ]
      end
      WSV.new(output).to_wsv(rjust: [2])
    end
  end
end
