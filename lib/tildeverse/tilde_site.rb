#!/usr/bin/env ruby

module Tildeverse
  #
  # Read site info from the input JSON file 'INPUT_TILDEVERSE'.
  class TildeSite
    attr_reader :name, :url_root, :url_list, :url_format_user

    # Pick up the URLs from the JSON, if not specified.
    def initialize(site_name, url_root = nil, url_list = nil)
      json = INPUT_TILDEVERSE['sites'][site_name]
      @name = site_name
      @url_root = url_root || json['url_root']
      @url_list = url_list || json['url_list']
      @url_format_user = json['url_format_user']
    end

    # Use the format string to map the user to their URL.
    # Example: 'https://tilde.town/~USER/'
    def user_page(user)
      @url_format_user.sub('USER', user)
    end

    # Cache results with the same info.
    # Optional argument to overwrite the userlist URL.
    def connection(url_list = nil)
      url_list ||= @url_list
      return @tc if @tc && @tc.url_list == url_list
      info = [@site_name, @url_root, url_list]
      @tc = TildeConnection.new(*info)
      @tc.get
      puts @tc.error_message if @tc.error
      @tc
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
