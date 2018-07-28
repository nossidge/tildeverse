#!/usr/bin/env ruby

module Tildeverse
  ##
  # Fetch the up-to-date TXT file from the remote URI.
  #
  class Fetcher
    ##
    # @return [Data] the underlying Data object
    #
    attr_reader :data

    ##
    # @param [Data] data
    #
    def initialize(data)
      @data = data
    end

    ##
    # Fetch the up-to-date TXT file from the remote URI.
    #
    # @return [Boolean] success state.
    #
    def fetch
      return false unless write_permissions?

      # Set up a connection to the remote TXT file.
      remote = RemoteResource.new('remote_txt', Files.remote_txt)

      # Try to get via HTTP, and return on failure.
      remote.get
      puts remote.msg or return false if remote.error?

      # Save the remote result verbatim, overwriting the existing file.
      Files.save_text(remote.result, Files.input_txt_tildeverse)

      # Use the new text file to load input.
      data.clear

      # Use the new text file to save output.
      data.save_with_config

      true
    end

    private

    ##
    # Check whether the current user has the correct OS permissions
    # to overwrite the file.
    #
    # @return [Boolean]
    #
    def write_permissions?
      return false unless Files.write?(Files.dir_input)
      filepath = Files.input_txt_tildeverse
      return true if !filepath.exist?
      Files.write?(filepath)
    end
  end
end
