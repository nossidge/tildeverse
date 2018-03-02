#!/usr/bin/env ruby
# Encoding: UTF-8

################################################################################
# Connection to a tilde box.
# Begin/rescue blocks for connection errors to the user list and root URL.
# Gives a sensible error string if either URL is offline.
# After #get is called, @result contains the URL resource contents,
#   unless the connection failed (then it's nil).
################################################################################

require 'net/http'
require 'net/https'
require 'open-uri'

################################################################################

module Tildeverse
  class TildeConnection
    attr_accessor :name
    attr_accessor :root_url
    attr_accessor :list_url
    attr_reader   :error
    attr_reader   :error_message
    attr_reader   :root_url_connection
    attr_reader   :list_url_connection
    attr_reader   :result

    # If the 'list_url' is not specified, assume it's the same as root.
    def initialize(name, root_url = nil, list_url = nil)
      @name = name
      @root_url = root_url
      @list_url = list_url
      @list_url = root_url if !root_url.nil? && list_url.nil?
    end

    def get

      # Test the user list page.
      begin
        page = open(@list_url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
        @result = page.read
        @list_url_connection = true
        @root_url_connection = true
      rescue
        @result = nil
        @list_url_connection = false
      end

      # If that failed, test the root page.
      if @list_url_connection == false
        begin
          open(@root_url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
          @root_url_connection = true
        rescue
          @root_url_connection = false
        end
      end

      # Set error message.
      if not @list_url_connection
        @error = true
        @error_message = "#{@name} user list is currently offline:  #{@list_url}"
      end
      if not @root_url_connection
        @error = true
        @error_message = "#{@name} is currently offline:  #{@root_url}"
      end

      # Return user list as the return value, if it didn't fail. Else return nil.
      @result
    end
  end
end

################################################################################
