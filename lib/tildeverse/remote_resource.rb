#!/usr/bin/env ruby
# frozen_string_literal: true

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
  # Raise a {Error::OfflineURIError} if either URL is offline.
  #
  class RemoteResource
    ##
    # @return [String] the name of the website
    # @example
    #   'example.com'
    #   'tilde.town'
    #
    attr_reader :name

    ##
    # @return [String] the root URL of the domain
    # @example
    #   'http://example.com/'
    #   'https://tilde.town/'
    #
    attr_reader :root

    ##
    # @return [String] the URL of the required resource
    # @example
    #   'http://example.com/users.html'
    #   'https://tilde.town/~dan/users.json'
    #
    attr_reader :resource

    ##
    # The result of the HTTP request to {#resource}.
    # Probably in HTML or JSON format
    # @return [String]
    # @return [nil] Before {#get} is called
    # @example
    #   <!DOCTYPE html>
    #   <html>
    #     ...
    #   </html>
    #
    attr_reader :result

    ##
    # Returns a new instance of RemoteResource.
    # All parameters are immutable once initialised
    #
    # @param [String] name
    #   An identifier for the connection
    # @param [String] root
    #   The root URL of the domain
    # @param [String] resource
    #   The URL of the required resource.
    #   If the 'resource' is not specified, assume it's the same as root
    #
    def initialize(name, root, resource = root)
      @name = name
      @root = root
      @resource = resource

      # Initial values, before #get is called
      @get_tried = false
      @valid_root = nil
      @valid_resource = nil
      @result = nil
    end

    ##
    # Try to return the resource located at {#resource}.
    # Set error flags and message if not able to connect
    #
    # @return {#result}
    # @raise [Error::OfflineURIError] if a remote URI is offline
    #
    def get!
      @get_tried = true
      try_connection_resource
      try_connection_root unless valid_resource?
      raise Error::OfflineURIError, offline_uri if error?

      @result
    end

    ##
    # (see #get!)
    # This method memoizes its return value, to avoid repeated requests
    #
    def get
      return @result if @get_tried
      get!
    end

    ##
    # Whether or not we can connect to the root URL
    #
    # @return [Boolean]
    # @return [nil] Before {#get} is called
    #
    def valid_root?
      @valid_root
    end

    ##
    # Whether or not we can connect to the resource URL
    #
    # @return [Boolean]
    # @return [nil] Before {#get} is called
    #
    def valid_resource?
      @valid_resource
    end

    ##
    # Whether or not there is an error with either URL
    #
    # @return [Boolean]
    # @return [nil] Before {#get} is called
    #
    def error?
      return nil unless @get_tried
      !valid_resource? || !valid_root?
    end

    private

    ##
    # On error, return which of the two URIs is offline
    #
    # @return [String]
    # @return [nil] Before {#get} is called, or if {#error?} is False
    #
    def offline_uri
      return nil unless error?
      !valid_root? ? @root : @resource
    end

    ##
    # Test the resource URL.
    # Do not raise an exeption for this, we will do it later
    #
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
    # Do not raise an exeption for this, we will do it later
    #
    # @return [Boolean]
    #
    def try_connection_root
      return true if valid_resource?

      # We don't need the actual response, just catch it on error
      open(@root, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
      @valid_root = true

    rescue StandardError
      @valid_root = false
    end
  end
end
