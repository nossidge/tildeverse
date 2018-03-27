#!/usr/bin/env ruby

module Tildeverse
  ##
  # Read site info from the input JSON file 'input_tildeverse'.
  #
  # This class exists to be inherited from. All classes in the
  # {Tildeverse::Site} namespace should be children of this class.
  #
  class TildeSite
    ##
    # (see Tildeverse::RemoteResource#name)
    #
    attr_reader :name

    ##
    # (see Tildeverse::RemoteResource#root)
    #
    attr_reader :root

    ##
    # (see Tildeverse::RemoteResource#resource)
    #
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
    # Use {#url_format_user} to map the user to their homepage URL.
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
    # Create a connection to the remote {#resource}.
    # Cache results with the same info, to reduce server load.
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

    private

    ##
    # @return [String] Message to return if no users are found.
    #
    def no_user_message
      "ERROR: No users found for site: #{@name}"
    end
  end
end
