#!/usr/bin/env ruby

module Tildeverse
  ##
  # Singleton class to store all the Tildeverse information.
  #
  # Relation model is:
  #   Data           (singleton)
  #   └── TildeSite  (has many)
  #       └── User   (has many)
  #
  # When first instantiated, it will automatically scrape all user
  # information through HTTP, or read from daily cache if present.
  #
  # Note that it is redundant in most cases to use this class directly,
  # as the main {Tildeverse} module implements {#site}, {#sites}, {#user},
  # and {#users} as class methods.
  # So instead of writing +Tildeverse::Data.instance.site+, you can just
  # use +Tildeverse.site+.
  #
  # @example
  #   Tildeverse::Data.instance.site('tilde.town')
  #   # => #<Tildeverse::Site::TildeTown:0x34e4608>
  # @example
  #   Tildeverse::Data.instance.site('tilde.town').user('nossidge')
  #   # => #<Tildeverse::User:0x34ec660>
  # @example
  #   Tildeverse::Data.instance.sites.select(&:online?).map(&:name)
  #   # => ['backtick.town', 'botb.club', ..., 'yourtilde.com']
  # @example
  #   Tildeverse::Data.instance.user('dave').map(&:email)
  #   # => ['dave@tilde.club', 'dave@tilde.town']
  #
  class Data
    include Singleton

    ##
    # @return [Array<TildeSite>] all sites in the Tildeverse
    #
    def sites
      sites_hash.values
    end

    ##
    # Find a site by name
    #
    # @param [String] site_name  Name of the site
    # @return [TildeSite] First matching site
    # @return [nil] If no site matches
    #
    def site(site_name)
      sites_hash[site_name]
    end

    ##
    # @return [Array<User>] a list of all online users in the Tildeverse
    #
    def users
      sites.map(&:users).flatten!
    end

    ##
    # Find a user by name, across the whole Tildeverse.
    # There may be multiple users with the same account name on different
    # sites, so the return must be an array.
    #
    # @return [Array<User>] a list of all users in the Tildeverse
    # @return [nil] if the user cannot be found
    #
    def user(user_name)
      [].tap do |array|
        sites.each do |site|
          user = site.user(user_name)
          array << user if user && user.online?
        end
      end
    end

    ##
    # Serialize data in the format of {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_tildeverse_json
      serialize_sites = {}.tap do |hash|
        sites_hash.each do |site_name, site|
          hash[site_name] = site.serialize_for_output
        end
      end
      {
        metadata: {
          url: 'http://tilde.town/~nossidge/tildeverse/',
          date_human: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
          date_unix: Time.now.to_i
        },
        sites: serialize_sites
      }
    end

    ##
    # Serialize data in the format of {Files#output_json_users}
    #
    # @return [Hash]
    #
    def serialize_users_json
      {}.tap do |h1|
        sites_hash.each_value do |site|
          h1[site.root] = {}.tap do |h2|
            site.users.map(&:name).each do |user|
              h2[user] = site.user_page(user)
            end
          end
        end
      end
    end

    private

    ##
    # This is the main storage object.
    # The key is the name of the site.
    #
    # @return [Hash{String => TildeSite}]
    #
    def sites_hash
      @sites_hash ||= {}.tap do |hash|
        Tildeverse::Site.classes.each do |klass|
          site = klass.new
          hash[site.name] = site
        end
      end
    end
  end
end
