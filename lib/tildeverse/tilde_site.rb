#!/usr/bin/env ruby

module Tildeverse
  #
  # Read site info from the input JSON file 'input_tildeverse'.
  class TildeSite
    attr_reader :name, :root, :resource, :url_format_user

    # Pick up the URLs from the JSON, if not specified.
    def initialize(site_name, root = nil, resource = nil)
      json = Tildeverse::Files.input_tildeverse['sites'][site_name]
      @name = site_name
      @root     = root     || json['url_root']
      @resource = resource || json['url_list']
      @url_format_user = json['url_format_user']
    end

    # Use the format string to map the user to their URL.
    # Example: 'https://tilde.town/~USER/'
    def user_page(user)
      @url_format_user.sub('USER', user)
    end

    # Cache results with the same info.
    # Optional argument to overwrite the userlist URL.
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

    # Does nothing here in the base class. Individual descendant
    #   classes should extend this with site-specific scrape code.
    def users
      []
    end

    # Find all descendants of this class.
    def self.descendants
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end

    private

    def no_user_message
      "ERROR: No users found for site: #{@name}"
    end
  end
end
