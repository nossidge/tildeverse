#!/usr/bin/env ruby

require 'abstract_type'

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
  # All child classes MUST define a method named +#scrape_users+.
  # This method defines how the user list is scraped on that site.
  #
  class Site
    include AbstractType
    abstract_method :scrape_users
    abstract_method :online?

    ##
    # @return [String] the name of the website
    # @example
    #   'example.com'
    #   'tilde.town'
    #
    attr_reader :name

    ##
    # @return [String] the root URL of the website
    # @example
    #   'http://example.com/'
    #   'https://tilde.town/'
    #
    attr_reader :url_root

    ##
    # @return [String] the URL of the user list
    # @example
    #   'http://example.com/users.html'
    #   'https://tilde.town/~dan/users.json'
    #
    attr_reader :url_list

    ##
    # @return [String]
    #   the format that the site uses to map users to their homepage.
    # @example
    #   'https://tilde.town/~USER/'
    #   'https://USER.remotes.club/'
    #
    attr_reader :homepage_format

    ##
    # Returns a new instance of Site.
    #
    # User array will be initialised with the contents of 'tildeverse.txt'
    # for that site. To get new users from remote location, run {#scrape}
    #
    # @param [String] name
    #   An identifier for the connection.
    # @param [String] url_root
    #   The root URL of the domain.
    # @param [String] url_list
    #   The URL of the user list.
    #   If list URL is not specified, assume it's the same as root URL.
    # @param [String] homepage_format
    #   The format that the site uses to map users to their homepage.
    #
    def initialize(name:, url_root:, url_list: url_root, homepage_format:)
      @name            = name
      @url_root        = url_root
      @url_list        = url_list
      @homepage_format = homepage_format

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
    # Use {#homepage_format} to map the user to their homepage URL.
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
      output = @homepage_format.sub('USER', user)

      # Throw error if '@homepage_format' does not contain USER substring.
      if @homepage_format == output
        msg  = '#homepage_format should be in the form eg: '
        msg += 'http://www.example.com/~USER/'
        raise ArgumentError, msg
      end
      output
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
    # Create a connection to the remote {#url_list}.
    # Cache results with the same info, to reduce server load.
    #
    # @param [String] url_list
    #   Optional argument to overwrite the {#resource} URL.
    # @return [RemoteResource] Connection to the remote {#resource}.
    #
    def connection(url_list = nil)
      url_list ||= @url_list
      return @remote if @remote && @remote.resource == url_list
      info = [name, url_root, url_list]
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
