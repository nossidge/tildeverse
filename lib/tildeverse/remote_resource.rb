#!/usr/bin/env ruby

module Tildeverse
  #
  # Connection to a remote resource via HTTP (or HTTPS).
  # If the required resource is not available, the root domain is checked.
  # This way, we can see if the whole site is offline, or just that page.
  # After #get is called, @result contains the URL resource contents,
  #   unless the connection failed (then it's nil).
  # Gives a sensible error string if either URL is offline.
  class RemoteResource
    attr_reader(
      :name,            # Not used in the code, just for reference.
      :root,            # The root URL: 'http://example.com/'
      :resource,        # The resource: 'http://example.com/users.html'
      :valid_root,      # Can connect to root URL?
      :valid_resource,  # Can connect to resource URL?
      :result,          # The result of the HTTP request.
      :msg,             # User-friendly error message. 'nil' if no errors.
    )

    # If the 'resource' is not specified, assume it's the same as root.
    def initialize(name, root = nil, resource = nil)
      @name = name
      @root = root
      @resource = resource
      @resource = root if !root.nil? && resource.nil?

      # Initial values, before #get is called.
      @get_tried = false
      @valid_root = nil
      @valid_resource = nil
      @result = nil
      @msg = nil
    end

    # Try to return the resource located at @resource.
    # Set error flags and message if not able to connect.
    def get!
      @get_tried = true
      try_connection_resource
      try_connection_root unless @valid_resource
      set_errors
      @result
    end

    # Cache results of subsequent #get method calls.
    def get
      return @result if @get_tried
      get!
      @result
    end

    # Is there an error with either URL?
    # Returns 'nil' if #get has not yet been called.
    def error?
      return nil unless @get_tried
      !@valid_resource || !@valid_root
    end

    private

    # Test the user list page.
    def try_connection_resource
      page = open(@resource, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
      @result = page.read
      @valid_resource = true
      @valid_root = true
    rescue StandardError
      @result = nil
      @valid_resource = false
    end

    # Test the root page.
    def try_connection_root
      return if @valid_resource

      # We don't need the actual response, just catch it if it fails.
      open(@root, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
      @valid_root = true
    rescue StandardError
      @valid_root = false
    end

    # Set error message.
    def set_errors
      return unless error?

      url = !@valid_root ? @root : @resource
      @msg = "URL is currently offline: #{url}"
    end
  end
end
