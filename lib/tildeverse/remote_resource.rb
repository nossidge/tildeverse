#!/usr/bin/env ruby

module Tildeverse
  ##
  # Connection to a remote resource via HTTP (or HTTPS).
  #
  # If the required {#resource} URL is not available, the {#root} domain URL
  # is checked. This way, we can see if just the resource URL or the whole
  # site is offline.
  #
  # After {#get} is called, {#result} contains the URL resource contents,
  # unless the connection failed (then it's nil).
  #
  # Gives a sensible error string in {#msg} if either URL is offline.
  #
  class RemoteResource
    ##
    # Not used in the code, just for reference.
    # @return [String]
    # @example
    #   'example'
    #   'tilde.town'
    #
    attr_reader :name

    ##
    # The root URL of the domain.
    # @return [String]
    # @example
    #   'http://example.com/'
    #   'https://tilde.town/'
    #
    attr_reader :root

    ##
    # The URL of the required resource.
    # @return [String]
    # @example
    #   'http://example.com/users.html'
    #   'https://tilde.town/~dan/users.json'
    #
    attr_reader :resource

    ##
    # The result of the HTTP request to {#resource}.
    # Probably in HTML or JSON format.
    # @return [String]
    # @return [nil] Before {#get} is called.
    # @example
    #   <!DOCTYPE html>
    #   <html>
    #     ...
    #   </html>
    #
    attr_reader :result

    ##
    # Returns a new instance of RemoteResource.
    # All parameters are immutable once initialised.
    # @param [String] name
    #   An identifier for the connection.
    # @param [String] root
    #   The root URL of the domain.
    # @param [String] resource
    #   The URL of the required resource.
    #   If the 'resource' is not specified, assume it's the same as root.
    #
    def initialize(name, root, resource = root)
      @name = name
      @root = root
      @resource = resource

      # Initial values, before #get is called.
      @get_tried = false
      @valid_root = nil
      @valid_resource = nil
      @result = nil
    end

    ##
    # Try to return the resource located at {#resource}.
    # Set error flags and message if not able to connect.
    # @return {#result}
    #
    def get!
      @get_tried = true
      try_connection_resource
      try_connection_root unless valid_resource?
      @result
    end

    ##
    # (see #get!)
    # This method caches its return value, to avoid repeated requests.
    #
    def get
      return @result if @get_tried
      get!
    end

    ##
    # Whether or not we can connect to the root URL.
    # @return [Boolean]
    # @return [nil] Before {#get} is called.
    #
    def valid_root?
      @valid_root
    end

    ##
    # Whether or not we can connect to the resource URL.
    # @return [Boolean]
    # @return [nil] Before {#get} is called.
    #
    def valid_resource?
      @valid_resource
    end

    ##
    # Whether or not there is an error with either URL.
    # @return [Boolean]
    # @return [nil] Before {#get} is called.
    #
    def error?
      return nil unless @get_tried
      !valid_resource? || !valid_root?
    end

    ##
    # User-friendly error message.
    # @return [String]
    # @return [nil] Before {#get} is called, or if {#error?} is False.
    # @example
    #   'URL is currently offline: http://example.com/users.html'
    #   'URL is currently offline: https://tilde.town/'
    #
    def msg
      return nil unless error?
      url = !valid_root? ? @root : @resource
      "URL is currently offline: #{url}"
    end

    private

    ##
    # Test the resource URL.
    # @return [Boolean]
    #
    def try_connection_resource
      page = open(@resource, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
      @result = page.read
      @valid_root = true
      @valid_resource = true
    rescue StandardError
      @result = nil
      @valid_resource = false
    end

    ##
    # Test the root URL.
    # @return [Boolean]
    #
    def try_connection_root
      return true if valid_resource?

      # We don't need the actual response, just catch it if it fails.
      open(@root, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
      @valid_root = true
    rescue StandardError
      @valid_root = false
    end
  end
end
