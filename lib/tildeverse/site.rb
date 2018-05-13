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
    # @return [String]
    #   the format that the site uses to map users to their homepage.
    # @example
    #   'https://tilde.town/~USER/'
    #   'https://USER.remotes.club/'
    #
    attr_reader :url_format_user

    ##
    # Returns a new instance of Site.
    #
    # User array will be initialised with the contents of 'tildeverse.txt'
    # for that site. To get new users from remote location, run {#scrape}
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
    # @return [Array<User>] all users of the site
    #
    def users
      @all_users.values.sort_by(&:name)
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

    ##
    # Query the remote resource to get the most up-to-date user list.
    # Add new users and update the information of existing users.
    #
    def scrape
      return unless online?

      # These are the users we already know about.
      existing_users = @all_users.keys.sort

      # These are the users from the remote list.
      remote_users = scrape_users.sort

      # TODO: Remove this:
      Files.save_array(remote_users, filepath)

      # Add new user accounts to @all_users.
      # They do not have 'tagged' or 'tags' data yet.
      new_users = remote_users - existing_users
      new_users.each do |user_name|
        @all_users[user_name] = User.new(
          site: self,
          name: user_name,
          date_online: Date.today.to_s,
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
    # Return site-specific data from {Tildeverse::Files#input_tildeverse}
    #
    # @return [Hash]
    #
    def users_from_input_tildeverse
      Tildeverse::Files.input_tildeverse_txt[name] || []
    end

    ##
    # Build up the @all_users hash, by finding user tagging data from
    # {Tildeverse::Files#input_tildeverse} and online users from the remote
    # location.
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
    # @return [String] 'no users found' message.
    #
    def no_user_message
      "ERROR: No users found for site: #{@name}"
    end
  end
end
