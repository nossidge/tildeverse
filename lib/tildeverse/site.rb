#!/usr/bin/env ruby

module Tildeverse
  ##
  # Class to store information for a particular site.
  #
  # Relation model is:
  #   Data
  #   └── Site       (has many)
  #       └── User   (has many)
  #
  # This class exists to be inherited from. All classes in the
  # {Tildeverse::Site} namespace should be children of this class.
  #
  # All child classes MUST define a method named {#scrape_users}.
  # This method defines how the user list is scraped on that site.
  #
  class Site
    include SiteSerializer

    ##
    # (see Tildeverse::RemoteResource#name)
    # .
    attr_reader :name

    ##
    # (see Tildeverse::RemoteResource#root)
    # .
    attr_reader :root

    ##
    # (see Tildeverse::RemoteResource#resource)
    # .
    attr_reader :resource

    ##
    # The format that the site uses to map users to their homepage.
    # @example
    #   'https://tilde.town/~USER/'
    #   'https://USER.remotes.club/'
    #
    attr_reader :url_format_user

    ##
    # Returns a new instance of Site.
    # All parameters are immutable once initialised.
    #
    # @param [String] name
    #   An identifier for the connection.
    # @param [String] root
    #   The root URL of the domain.
    # @param [String] resource
    #   The URL of the user list.
    #   If the resource is not specified, assume it's the same as root.
    # @param [String] url_format_user
    #   The format that the site uses to map users to their homepage.
    #
    def initialize(name: nil, root: nil, resource: root, url_format_user: nil)
      raise NoMethodError unless name

      @name            = name
      @root            = root
      @resource        = resource
      @url_format_user = url_format_user

      initialize_users
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
    # Since this is the 'public' interface for this class, only return those
    # users who are online. I can't imagine any situation where another class
    # will need to know about old users.
    #
    # @return [Array<User>] All users of the site
    #
    def users
      @all_users.values.select(&:online?).sort_by(&:name)
    end

    ############################################################################

    ##
    # @return [Boolean] the site's known online status.
    #
    def self.online?
      true
    end

    ##
    # @return [Boolean] the site's known online status.
    #
    def online?
      self.class.online?
    end

    ############################################################################

    ##
    # Use {#url_format_user} to map the user to their homepage URL.
    #
    # @param [String] user The name of the user.
    # @return [String] user's homepage.
    # @example
    #   tilde_town = Site.new('tilde.town')
    #   tilde_town.user_page('imt')
    #   # => 'https://tilde.town/~imt/'
    # @example
    #   remotes_club = Site.new('remotes.club')
    #   remotes_club.user_page('imt')
    #   # => 'https://imt.remotes.club/'
    #
    def user_page(user)
      @url_format_user.sub('USER', user)
    end

    ##
    # Use {#name} to map the user to their email address
    #
    # @param [String] user The name of the user
    # @return [String] user's email address
    # @example
    #   tilde_town = Site.new('tilde.town')
    #   tilde_town.email('nossidge')
    #   # => 'nossidge@tilde.town'
    # @note
    #   On most Tilde servers, this is valid for local email only
    #
    def user_email(user)
      "#{user}@#{name}"
    end

    ############################################################################

    private

    ##
    # Return site-specific data from {Tildeverse::Files#input_tildeverse}
    #
    # @return [Hash]
    #
    def users_from_input_tildeverse
      Tildeverse::Files.input_tildeverse_txt.dig('sites', name, 'users') || []
    end

    ##
    # Build up the @all_users hash, by finding user tagging data from
    # {Tildeverse::Files#input_tildeverse} and online users from the remote
    # location. This will set the data that can be read by @users_tagged
    # and @users_online
    #
    def initialize_users
      #
      # Create the list of all users.
      # Initially, this will be just those users from the 'input' JSON.
      @all_users = {}.tap do |hash|
        users = users_from_input_tildeverse
        users.each do |user_name, user_hash|

          # Grab the most recent cached info from 'tildeverse.txt'
          from_input_txt = users[user_name]

          # Create a new User instance using the cached data.
          hash[user_name] = User.new(
            site: self,
            name: user_name,
            date_online: from_input_txt[:date_online],
            date_offline: from_input_txt[:date_offline],
            date_modified: from_input_txt[:date_modified],
            date_tagged: from_input_txt[:date_tagged],
            tags: from_input_txt[:tags]
          )
        end
      end
      @users_tagged = @all_users.keys.sort

      # Scrape the online users, to find any new accounts.
      new_users = scrape_online_users - @users_tagged

      # Add the new users to @all_users.
      # They do not have 'tagged' or 'tags' data yet.
      new_users.each do |u_name|
        @all_users[u_name] = User.new(
          site: self,
          name: u_name
        )
      end

      # Set the 'online' value of each user.
      @users_online.each do |u_name|
        @all_users[u_name].online = true
      end
    end

    ##
    # Create a connection to the remote {#resource}.
    # Cache results with the same info, to reduce server load.
    #
    # @param [String] resource
    #   Optional argument to overwrite the {#resource} URL.
    # @return [RemoteResource] Connection to the remote {#resource}.
    #
    def connection(resource = nil)
      resource ||= @resource
      return @remote if @remote && @remote.resource == resource
      info = [name, @root, resource]
      @remote = RemoteResource.new(*info)
      @remote.get
      puts @remote.msg if @remote.error?
      @remote
    end
    alias con connection

    ##
    # Return the users of this Tilde site. In order to reduce HTTP requests,
    # read from a cached instance variable, or from today's user list file,
    # if either exist.
    #
    # @return [Array<String>] the online users of the site.
    #
    def scrape_online_users
      return @users_online = [] unless online?
      return @users_online if @users_online
      return @users_online = read_users_from_file if filepath.exist?
      scrape_online_users!
    end

    ##
    # Return the users of this Tilde site. Scrape this directly from the
    # remote server, ignoring and overwriting any existing user list data.
    #
    # @return [Array<String>] the online users of the site.
    #
    def scrape_online_users!
      @users_online = scrape_users.sort
      Files.save_array(@users_online, filepath)
      @users_online
    end

    ##
    # This needs to be overwritten by child classes. It should specify how
    # to scrape the tilde server remote resource to return the users.
    #
    # @raise [NoMethodError]
    #
    def scrape_users
      raise NoMethodError, 'Method should be overwritten by a child class'
    end

    ##
    # @return [Pathname]
    #   location of the site directory within the {Files#dir_output}.
    #
    def pathname
      path = Files.dir_output + 'sites' + name
      Files.makedirs(path) unless path.exist?
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
    # Read user list from today's cached file.
    # @return [Array] list of users.
    #
    def read_users_from_file
      open(filepath).readlines.map(&:chomp).sort
    end

    ##
    # @return [String] 'no users found' message.
    #
    def no_user_message
      "ERROR: No users found for site: #{@name}"
    end
  end
end
