#!/usr/bin/env ruby

module Tildeverse
  ##
  # Class to store all the Tildeverse information.
  #
  # Relation model is:
  #   Data
  #   └── Site       (has many)
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
    include DataSerializer

    ##
    # @return [Date] the date {Files#output_tildeverse} was last updated
    #
    def last_updated
      json = Files.output_tildeverse
      date_unix = json.dig('metadata', 'date_unix')
      Time.at(date_unix).to_date
    end

    ##
    # @return [Boolean] whether {Files#output_tildeverse} was updated today
    #
    def updated_today?
      last_updated == Date.today
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
    # @param [String] site_name  Name of the site
    # @return [Site] First matching site
    # @return [nil] If no site matches
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
    # Serialise data to files 'tildeverse.txt' and 'tildeverse.json'
    #
    def save
      wsv = serialize_tildeverse_txt
      file = Files.dir_input + 'tildeverse.txt'
      Files.save_array(wsv, file)

      json = serialize_tildeverse_json
      file = Files.output_json_tildeverse
      Files.save_json(json, file)
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
        Tildeverse::Sites.classes.each do |klass|
          site = klass.new
          hash[site.name] = site
        end
      end
    end
  end
end
