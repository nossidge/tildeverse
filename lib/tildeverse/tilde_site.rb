#!/usr/bin/env ruby

################################################################################
# Read site info from the input JSON file 'INPUT_TILDEVERSE'.
################################################################################

module Tildeverse
  class TildeSite
    attr_reader :name, :url_root, :url_list, :url_format_user

    def initialize(site_name)
      json = INPUT_TILDEVERSE['sites'][site_name]
      @name = site_name
      @url_root = json['url_root']
      @url_list = json['url_list']
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
  end
end

################################################################################
