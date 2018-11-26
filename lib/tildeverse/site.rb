#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  ##
  # Abstract class to store information for a particular site.
  #
  # Relation model is:
  #   Data
  #   └── Site       (has many)
  #       └── User   (has many)
  #
  # This class exists to be inherited from. All classes in the
  # {Tildeverse::Sites} namespace should be children of this class.
  #
  # All child classes MUST define a method named +#scrape_users+.
  # This method defines how the user list is scraped on that site.
  #
  # Also necessary is a class method named +#online?+.
  # This should return the site's known online status.
  #
  class Site
    ##
    # Abstract method, to be implemented by inheritors
    # @abstract
    # @return [Array<String>] list of user names
    # @raise [Error::AbstractMethodError]
    #
    def scrape_users
      raise Error::AbstractMethodError, __method__
    end

    ##
    # Abstract class method, to be implemented by inheritors
    # @abstract
    # @return [Boolean] the site's known online status
    # @raise [Error::AbstractMethodError]
    #
    def self.online?
      raise Error::AbstractMethodError, __method__
    end

    ############################################################################

    ##
    # @return [TildeSiteURI] the URI of the user list
    #
    attr_reader :uri

    ##
    # (see Tildeverse::TildeSiteURI#name)
    #
    def name
      uri.name
    end

    ##
    # Returns a new instance of Site.
    #
    # User array will be initialised with the contents of 'tildeverse.txt'
    # for that site. To get new users from remote location, run {#scrape}
    #
    # @param [URI] uri
    #
    def initialize(uri)
      @uri = uri
      initialize_users
    end

    ##
    # @return [SiteSerializer] serializer object
    #
    def serialize
      SiteSerializer.new(self)
    end

    ##
    # @return [String] string representation of the object
    #
    def to_s
      serialize.to_s
    end

    ##
    # @return [Boolean] the site's known online status.
    #
    def online?
      self.class.online?
    end

    ############################################################################

    ##
    # Find a user by name.
    # This will return the full User object, with tag data included.
    #
    # @param [String] user_name The name of the user
    # @return [User] First matching user
    # @return [nil] If no user matches
    #
    def user(user_name)
      @all_users[user_name]
    end

    ##
    # @return [Array<User>] all users of the site
    #
    def users
      @all_users.values.sort_by(&:name)
    end

    ##
    # @return [Array<User>] all users that are online
    #
    def users_online
      users.select(&:online?)
    end

    ############################################################################

    ##
    # Query the remote resource to get the most up-to-date user list.
    # Add new users and update the information of existing users.
    #
    def scrape
      return unless online?

      # These are the users we already know about.
      existing_users = @all_users.keys.sort

      # These are the users from the remote list.
      remote_users = scrape_users_cache.sort

      # Add new user accounts to @all_users.
      # They do not have 'tagged' or 'tags' data yet.
      new_users = remote_users - existing_users

      new_users.each do |user_name|
        @all_users[user_name] = User.new(
          site: self,
          name: user_name,
          date_online: Date.today
        )
      end

      # Flag newly dead user accounts to date_offline = today.
      dead_users = existing_users - remote_users
      dead_users.each do |user_name|
        user = @all_users[user_name]
        user.date_offline = Date.today if user.online?
      end

      # If a 'new' account was previously marked as offline, remove the
      # 'date_offline' attribute while keeping the existing 'date_online'.
      # This might naturally occur if a site goes offline for a few days.
      remote_users.each do |user_name|
        user = @all_users[user_name]
        user.date_offline = TildeDate.new(nil)
      end
    end

    ############################################################################

    private

    ##
    # Memoize the result, or return [] if site is confirmed offline
    #
    # @return [Array<String>] all users of the site
    #
    def scrape_users_cache
      return @scrape_users_cache if @scrape_users_cache
      return @scrape_users_cache = [] if connection.error?
      scrape_users
    end

    ##
    # Return site-specific data from {Tildeverse::Files#input_tildeverse}
    #
    # @return [Hash]
    #
    def users_from_input_tildeverse
      Tildeverse::Files.input_tildeverse_txt_as_hash[name] || {}
    end

    ##
    # Build up the @all_users hash, by finding user tagging data from
    # {Tildeverse::Files#input_tildeverse} and online users from the remote
    # location.
    #
    def initialize_users
      #
      # Create a new User instance for all users, using the cached data.
      # Initially, this will be just those users from 'tildeverse.txt'
      @all_users = {}.tap do |hash|
        users = users_from_input_tildeverse
        users.each do |user_name, user_hash|
          hash[user_name] = User.new(
            site:           self,
            name:           user_name,
            date_online:    user_hash[:date_online],
            date_offline:   user_hash[:date_offline],
            date_modified:  user_hash[:date_modified],
            date_tagged:    user_hash[:date_tagged],
            tags:           user_hash[:tags]
          )
        end
      end
    end

    ##
    # Create a connection to the remote {#uri.list}.
    # Memoize results with the same info, to reduce server load.
    #
    # @param [String] url
    #   Optional argument to overwrite the {#resource} URL.
    # @return [RemoteResource] Connection to the remote {#resource}.
    #
    def connection(url = uri.list)
      return @remote if @remote && @remote.resource == url
      info = [name, uri.root, url]
      @remote = RemoteResource.new(*info).tap do |remote|
        Tildeverse.suppress.handle(Error::OfflineURIError) do
          remote.get
        end
      end
    end
    alias con connection

    ##
    # Yield to a block, and output a message to console if the block produces
    # an empty array. In any case, return the value of the block.
    #
    # @yield
    #   code to get a list of usernames, most likely from a remote URI
    # @yieldreturn [Array<String>] list of usernames
    # @return [Array<String>] list of usernames (from the yielded block)
    # @raise [Error::NoUsersFoundError] if user list is empty
    #
    def validate_usernames
      yield.tap do |usernames|
        raise Error::NoUsersFoundError, name if usernames.empty?
      end
    end
  end
end
