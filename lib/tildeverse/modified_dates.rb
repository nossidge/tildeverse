#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  ##
  # Scrape modified dates from ~insom's list,
  # http://tilde.town/~insom/modified.html
  #
  # Use {#get} to scrape data, or return the most recent cache
  #
  # Use {#get!} to overwrite the cache with a new remote scrape
  #
  class ModifiedDates
    ##
    # Remotely read ~insom's list, using RemoteResource to fetch via HTTP
    #
    # @return [Hash{String => Hash{String => Date}}]
    #   Hash of hashes that describe a user's updated date
    # @example
    #   data["tilde.town"]["nossidge"] == "2017-04-02"
    #
    def get
      @data ||= get!
    end

    ##
    # (see #get)
    #
    # This overwrites the data with updated information
    #
    def get!
      @data = parse_data(read_data)
    end

    ##
    # Return the modified date for a specific user page
    #
    # @param site [String] name of the server
    # @param user [String] name of the user
    # @return [Date] user's updated date
    # @return [nil] if not found
    #
    def for_user(site, user)
      get[site][user]
    end

    private

    ##
    # Set up a connection to the remote HTML file
    #
    # @return [RemoteResource]
    #
    def remote
      return @remote if @remote
      info = [
        'insom/modified',
        'http://tilde.town/~insom/',
        'http://tilde.town/~insom/modified.html'
      ]
      @remote = RemoteResource.new(*info)
    end

    ##
    # Remotely read ~insom's list, using RemoteResource to fetch via HTTP
    #
    # @return [Array<String>]
    #   Array of HTML lines that describe a user's updated date
    #
    def read_data
      remote.get.split("\n").select { |i| i.match('<a href') }
    end

    ##
    # Parse ~insom's HTML formatted lines to a usable hash
    #
    # @param [Array<String>] input_data
    #   Array of HTML lines that describe a user's updated date
    # @return [Hash{String => Hash{String => Date}}]
    #   Hash of hashes that describe a user's updated date
    # @example
    #   data["tilde.town"]["nossidge"] == "2017-04-02"
    #
    def parse_data(input_data)
      Hash.new { |h, k| h[k] = {} }.tap do |hash|
        input_data.each do |i|
          i = i
              .gsub!('<br/>', '')
              .gsub!('</a>', '')
              .split('>')[1..-1].join
          site = i.split('/')[2]
          user = i.split('/')[3].delete('~')
          date = i.split(' -- ')[1].split('T').first
          hash[site][user] = Date.parse(date)
        end
      end
    end
  end
end
