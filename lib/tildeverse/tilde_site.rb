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
    # (see Tildeverse::RemoteResource#initialize)
    #
    # Similar to {Tildeverse::RemoteResource#initialize}, except that only
    # the site name needs to be specified. The root and resource parameters
    # will be looked up using {Tildeverse::Files#input_tildeverse}.
    #
    def initialize(name, root = nil, resource = nil)
      json      = Tildeverse::Files.input_tildeverse['sites'][name]
      @name     = name
      @root     = root     || json['url_root']
      @resource = resource || json['url_list']
      @url_format_user = json['url_format_user']
    end

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

    ##
    # Return the users of this Tilde site. In order to reduce HTTP requests,
    # read from a cached instance variable, or from today's user list file,
    # if either exist.
    #
    # @return [Array<String>] the users of the site.
    #
    def users
      return [] unless online?
      return @users if @users
      return read_users_from_file if filepath.exist?
      users!
    end

    ##
    # Return the users of this Tilde site. Scrape this directly from the
    # remote server, ignoring and overwriting any existing user list data.
    #
    # @return [Array<String>] the users of the site.
    #
    def users!
      @users = scrape_users
      Files.save_array(@users, filepath)
      @users
    end

    private

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
      open(filepath).readlines.map(&:chomp)
    end

    ##
    # @return [String] 'no users found' message.
    #
    def no_user_message
      "ERROR: No users found for site: #{@name}"
    end
  end
end
