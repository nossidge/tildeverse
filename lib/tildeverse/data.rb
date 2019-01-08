#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  ##
  # Class to store all the Tildeverse information.
  #
  # Relation model is:
  #   Data
  #   └── Site       (has many)
  #       └── User   (has many)
  #
  # Note that it is redundant in most cases to use this class directly,
  # as the main {Tildeverse} module creates an instance that can be globally
  # accessed. {Tildeverse} implements {#site}, {#sites}, {#user}, and {#users}
  # as class method proxies to this instance.
  # So instead of writing +Tildeverse::Data.new.site+, or
  # +Tildeverse.data.site+, you should just use +Tildeverse.site+.
  #
  # @example
  #   Tildeverse::Data.new.site('tilde.town')
  #   #=> Tildeverse::Sites::TildeTown
  # @example
  #   Tildeverse::Data.new.site('tilde.town').user('nossidge')
  #   #=> Tildeverse::User
  # @example
  #   Tildeverse::Data.new.sites.select(&:online?).map(&:name)
  #   #=> ['crime.team', 'ctrl-c.club', ..., 'yourtilde.com']
  # @example
  #   Tildeverse::Data.new.user('dave').map(&:email)
  #   #=> ['dave@riotgirl.club', 'dave@tilde.club', 'dave@tilde.town']
  #
  class Data
    ##
    # @return [Config] Config object to use for certain decisions
    #
    attr_reader :config

    ##
    # Creates a new {Data} object. The {#config} parameter is used when
    # fetching remote data or saving to file.
    #
    # @param config [Config] Config object to use for certain decisions
    #
    def initialize(config = Tildeverse::Config.new)
      @config = config
    end

    ##
    # @return [DataSerializer] serializer object
    #
    def serialize
      DataSerializer.new(self)
    end

    ##
    # @return [Array<Site>] all sites in the Tildeverse
    #
    def sites
      sites_hash.values
    end

    ##
    # Find a site by name
    #
    # @param site_name [String] name of the site
    # @return [Site] first matching site
    # @return [nil] if no site matches
    #
    def site(site_name)
      sites_hash[site_name]
    end

    ##
    # @return [Array<User>] the list of all users in the Tildeverse
    #
    def users
      sites.map!(&:users).flatten!
    end

    ##
    # Find a user by name, across the whole Tildeverse.
    # There may be multiple users with the same account name on different
    # sites, so the return must be an array.
    #
    # @return [Array<User>] the list of all matching users in the Tildeverse
    #
    def user(user_name)
      users.select! { |i| i.name == user_name }
    end

    ##
    # (see Tildeverse::DataSaver#save)
    #
    def save
      DataSaver.new(self).save
    end

    ##
    # Clear all the data
    #
    def clear
      @sites_hash = nil
    end

    private

    ##
    # This is the main storage object.
    # The key is the name of the site.
    #
    # @return [Hash{String => Site}]
    #
    def sites_hash
      @sites_hash ||= {}.tap do |hash|
        Sites.classes.each do |klass|
          site = klass.new
          hash[site.name] = site
        end
      end
    end
  end
end
