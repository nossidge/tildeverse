#!/usr/bin/env ruby

module Tildeverse
  ##
  # Read site info from the input JSON file 'input_tildeverse'.
  #
  # This class exists to be inherited from. All classes in the
  # {Tildeverse::Site} namespace should be children of this class.
  #
  # All child classes MUST define a method named {#scrape_users}.
  # This method defines how the user list is scraped on that site.
  #
  class TildeSite
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
    # User names scraped for the 'output' JSON.
    # Some of these may be new users that have no tags yet.
    #
    # @return [Array<String>]
    #
    attr_reader :users_online

    ##
    # User names from the 'input' JSON.
    # Some of these may no longer be online.
    #
    # @return [Array<String>]
    #
    attr_reader :users_tagged

    ##
    # (see Tildeverse::RemoteResource#initialize)
    #
    # Similar to {Tildeverse::RemoteResource#initialize}, except that only
    # the site name needs to be specified. The root and resource parameters
    # will be looked up using {Tildeverse::Files#input_tildeverse}.
    #
    def initialize(name, root = nil, resource = nil)
      @name     = name
      json      = data_from_input_tildeverse
      @root     = root     || json['url_root']
      @resource = resource || json['url_list']
      @url_format_user = json['url_format_user']

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
    # (see #scrape_online_users)
    #
    def users
      scrape_online_users
    end

    ##
    # (see #scrape_online_users!)
    #
    def users!
      scrape_online_users!
    end

    ############################################################################

    ##
    # Serialize the data for writing to {Files#output_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_for_output
      serialize(users_online, 'output')
    end

    ##
    # Serialize the data for writing to {Files#input_json_tildeverse}
    #
    # @return [Hash]
    #
    def serialize_for_input
      serialize(users_tagged, 'input')
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
      info = [@site_name, @root, resource]
      @remote = RemoteResource.new(*info)
      @remote.get
      puts @remote.msg if @remote.error?
      @remote
    end
    alias con connection

    ##
    # Use {#url_format_user} to map the user to their homepage URL.
    #
    # @param [String] user The name of the user.
    # @return [String] user's homepage.
    # @example
    #   tilde_town = TildeSite.new('tilde.town')
    #   tilde_town.user_page('imt')
    #   # => 'https://tilde.town/~imt/'
    # @example
    #   remotes_club = TildeSite.new('remotes.club')
    #   remotes_club.user_page('imt')
    #   # => 'https://imt.remotes.club/'
    #
    def user_page(user)
      @url_format_user.sub('USER', user)
    end

    ############################################################################

    private

    ##
    # Return site-specific data from {Tildeverse::Files#input_tildeverse}
    #
    # @return [Hash]
    #
    def data_from_input_tildeverse
      Tildeverse::Files.input_tildeverse['sites'][name]
    end

    ##
    # Build up the @all_users hash, by finding user tagging data from
    # {Tildeverse::Files#input_tildeverse} and online users from the remote
    # location. This will set the data that can be read by {#users_tagged}
    # and {#users_online}
    #
    # @return [nil]
    #
    def initialize_users
      site_name = name

      # Create the list of all users.
      # Initially, this will be just those users from the 'input' JSON.
      @all_users = {}.tap do |hash|
        users = data_from_input_tildeverse['users'] || []
        users.each do |user_name, user_hash|
          hash[user_name] = User.new(
            site_name,
            user_name,
            user_hash['tagged'],
            user_hash['tags']
          )
        end
      end
      @users_tagged = @all_users.keys.sort

      # Scrape the online users, to find any new accounts.
      new_users = scrape_online_users - users_tagged

      # Add the new users to @all_users.
      # They do not have 'tagged' or 'tags' data yet.
      new_users.each do |u_name|
        @all_users[u_name] = User.new(site_name, u_name)
      end

      # Set the 'online' value of each user.
      users_online.each do |u_name|
        @all_users[u_name].online = true
      end

      nil
    end

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
    # Serialize the data
    #
    # @param [Array<String>] users_array list of user names to display
    # @param [String] type either 'input' or 'output'
    #
    def serialize(users_array, type)
      raise ArgumentError unless %w[input output].include?(type)
      {}.tap do |hash|
        hash[:url_root]        = root
        hash[:url_list]        = resource
        hash[:url_format_user] = url_format_user
        hash[:online]          = online?           if type == 'output'
        hash[:user_count]      = users_array.count if type == 'output'
        hash[:users]           = serialize_users(users_array, type)
      end
    end

    ##
    # @param [Array<String>] users_array list of user names to display
    # @param [String] type either 'input' or 'output'
    # @return [Hash]
    #
    def serialize_users(users_array, type)
      raise ArgumentError unless %w[input output].include?(type)
      {}.tap do |hash|
        users_array.each do |user|
          hash[user] = @all_users[user].send("serialize_#{type}")
        end
      end
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
