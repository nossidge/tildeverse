#!/usr/bin/env ruby

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
    # @raise [NotImplementedError]
    #
    def scrape_users
      msg = "Abstract method '##{__method__}' " \
            'not implemented at this level of inheritance'
      raise NotImplementedError, msg
    end

    ##
    # Abstract class method, to be implemented by inheritors
    # @raise [NotImplementedError]
    #
    def self.online?
      msg = "Abstract method '##{__method__}' " \
            'not implemented at this level of inheritance'
      raise NotImplementedError, msg
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
    # @return [Boolean] the site's known online status.
    #
    def online?
      self.class.online?
    rescue NoMethodError
      raise NotImplementedError, '#online? class method is not implemented'
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

      # TODO: Remove this:
      Files.save_array(remote_users, filepath)

      # Add new user accounts to @all_users.
      # They do not have 'tagged' or 'tags' data yet.
      new_users = remote_users - existing_users

      new_users.each do |user_name|
        @all_users[user_name] = User.new(
          site: self,
          name: user_name,
          date_online: Date.today.to_s
        )
      end

      # Flag newly dead user accounts to date_offline = today.
      dead_users = existing_users - remote_users
      dead_users.each do |user_name|
        user = @all_users[user_name]
        user.date_offline = Date.today.to_s if user.online?
      end

      # If a 'new' account was previously marked as offline, remove the
      # 'date_offline' attribute while keeping the existing 'date_online'.
      # This might naturally occur if a site goes offline for a few days.
      remote_users.each do |user_name|
        user = @all_users[user_name]
        user.date_offline = '-'
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
      return @scrape_users_cache = [] if con.error?
      scrape_users
    end

    ##
    # Return site-specific data from {Tildeverse::Files#input_tildeverse}
    #
    # @return [Hash]
    #
    def users_from_input_tildeverse
      Tildeverse::Files.input_tildeverse_txt[name] || {}
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
      @remote = RemoteResource.new(*info)
      @remote.get
      puts @remote.msg if @remote.error?
      @remote
    end
    alias con connection

    ##
    # @return [Pathname]
    #   location of the site directory within the {Files#dir_output}.
    #
    def pathname
      path = Files.dir_output + 'sites' + name
      FileUtils.makedirs(path) unless path.exist?
      path
    end

    ##
    # @return [String] name of the current day's user list file.
    #
    def filename
      date_now = Time.now.strftime('%Y%m%d')
      date_now + '.txt'
    end

    ##
    # @return [Pathname] full path to the {#filename}.
    #
    def filepath
      pathname + filename
    end

    ##
    # @return [String] 'no users found' message.
    #
    def no_user_message
      "ERROR: No users found for site: #{name}"
    end
  end
end
