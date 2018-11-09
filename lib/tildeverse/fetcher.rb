#!/usr/bin/env ruby
# frozen_string_literal: true

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
    # @return [RemoteResource] a connection to the remote TXT file
    #
    attr_reader :remote

    ##
    # @param [Data] data
    # @param [RemoteResource] remote
    #
    def initialize(data, remote = nil)
      @data = data
      @remote = remote
      @remote ||= RemoteResource.new('remote_txt', Files.remote_txt)
    end

    ##
    # Fetch the up-to-date TXT file from the remote URI.
    #
    # Requires write-access to the underlying data files, so raises an error
    # if permission is denied.
    #
    # @raise [Error::DeniedByConfig]
    #   if user is not authorised for write-access by the config
    #
    def fetch
      raise Error::DeniedByConfig unless data.config.authorised?

      # Try to get the remote file via HTTP.
      remote.get

      # Copy the existing 'tildeverse.txt' file as a backup.
      original = Files.input_txt_tildeverse
      backup   = Files.input_txt_tildeverse_fetch_backup
      FileUtils.cp(original, backup) if original.exist?

      # Save the remote result verbatim, overwriting the existing file.
      Files.save_text(remote.result, Files.input_txt_tildeverse)

      # Use the new text file to load input.
      data.clear

      # Update to include any local tags.
      TagMerger.new(data, backup).merge if backup.exist?

      # Remove the backup file.
      FileUtils.rm(backup) if backup.exist?

      # Use the new text file to save output.
      data.save_with_config
    end
  end
end
