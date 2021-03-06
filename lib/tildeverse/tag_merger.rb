#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  ##
  # Update the user homepage tag information using tags read in from a
  # separate file. Useful during a {Fetcher#fetch} operation to update the
  # automated information while keeping tag-based changes from the local file
  #
  class TagMerger
    ##
    # @return [Data] the underlying Data object
    #
    attr_reader :data

    ##
    # @return [Pathname]
    #   File in the same format as 'tildeverse.txt' containing newer user tags
    #
    attr_reader :filepath

    ##
    # Creates a new {TagMerger}
    #
    # @param [Data] data
    # @param [Pathname] filepath
    #   File in the same format as 'tildeverse.txt' containing newer user tags
    #
    def initialize(data, filepath)
      @data = data
      @filepath = filepath
    end

    ##
    # Read in the data from the file at {#filepath} and overwrite existing
    # tags if the new tags are from a later date.
    #
    # Don't forget to {Data#save} the results to file afterwards if you
    # want the updates to be permanent.
    #
    def merge
      read_file.each do |i|
        user = data.site(i[:site_name])&.user(i[:user_name])
        next unless user

        # Determine if the tagged date is newer than the current
        current = TildeDate.new(user.date_tagged)
        newer   = TildeDate.new(i[:date_tagged])
        tags_are_newer = current < newer

        # Update if necessary
        if tags_are_newer
          tags = i[:tags].split(',')
          user.tags = TagArray.new(tags, validation: false)
          user.update_date_tagged!(newer)
        end
      end
    end

    private

    ##
    # @return [Array<Hash>] Array containing each line of the file as a hash
    #
    def read_file
      contents = Files.read_utf8(filepath)
      wsv = WSV.new(contents.split("\n"))
      wsv.from_wsv_with_header
    end
  end
end
