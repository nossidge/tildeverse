#!/usr/bin/env ruby

module Tildeverse
  ##
  # Fetch the up-to-date TXT file from the remote URI.
  #
  class Fetcher
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
      filepath = Files.dir_input + 'tildeverse.txt'
      Files.save_text(remote.result, filepath)

      # Use the new text file to load input.
      Tildeverse.data!

      # Use the new text file to save output.
      Tildeverse.save

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
      filepath = Files.dir_input + 'tildeverse.txt'
      Files.write?(filepath)
    end
  end
end
