#!/usr/bin/env ruby

module Tildeverse
  #
  # Connection to a tilde box.
  # Begin/rescue blocks for connection errors to the user list and root URL.
  # Gives a sensible error string if either URL is offline.
  # After #get is called, @result contains the URL resource contents,
  #   unless the connection failed (then it's nil).
  class TildeConnection
    attr_accessor :name, :url_root, :url_list
    attr_reader :result, :error, :error_message
    attr_reader :url_root_connection, :url_list_connection

    # If the 'url_list' is not specified, assume it's the same as root.
    def initialize(name, url_root = nil, url_list = nil)
      @name = name
      @url_root = url_root
      @url_list = url_list
      @url_list = url_root if !url_root.nil? && url_list.nil?
    end

    # Return user list as the return value, if it didn't fail. Else return nil.
    def get
      try_connection_list
      try_connection_root unless @url_list_connection
      set_errors
      @result
    end

    private

    # Test the user list page.
    def try_connection_list
      page = open(@url_list, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
      @result = page.read
      @url_list_connection = true
      @url_root_connection = true
    rescue StandardError
      @result = nil
      @url_list_connection = false
    end

    # Test the root page.
    def try_connection_root
      return if @url_list_connection

      open(@url_root, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
      @url_root_connection = true
    rescue StandardError
      @url_root_connection = false
    end

    # Set error message.
    def set_errors
      @error = !@url_list_connection || !@url_root_connection
      return unless @error

      url = !@url_root_connection ? url_root : url_list
      @error_message = "URL is currently offline: #{url}"
    end
  end
end
