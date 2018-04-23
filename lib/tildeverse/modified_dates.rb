#!/usr/bin/env ruby

require 'singleton'

module Tildeverse
  ##
  # Scrape modified dates from ~insom's list,
  # http://tilde.town/~insom/modified.html.
  #
  # This is a singleton, in order to keep remote requests
  # cached throughout the runtime.
  #
  # Use {#get} to overwrite the cache with a new remote scrape.
  #
  # Use {#data} to return the most recent cache.
  #
  class ModifiedDates
    include Singleton

    ##
    # @return [Array<Hash{Symbol => String}>]
    #   Array of hashes that describe a user's updated time.
    # @example
    #   [
    #     {
    #       :site => "tilde.town",
    #       :user => "nossidge",
    #       :time => "2017-04-02T07:18:44"
    #     }
    #   ]
    #
    attr_reader :data

    ##
    # On initialisation, call {#get}
    #
    def initialize
      get
    end

    ##
    # Remotely read ~insom's list, using RemoteResource to fetch via HTTP.
    # Save the result to a cache file.
    #
    # If the list has already been scraped today, read from the cached file.
    #
    # This overwrites {#data} with updated information.
    #
    # @return [Array<Hash{Symbol => String}>]
    #   Array of hashes that describe a user's updated time.
    # @example
    #   [
    #     {
    #       :site => "tilde.town",
    #       :user => "nossidge",
    #       :time => "2017-04-02T07:18:44"
    #     }
    #   ]
    #
    def get
      @data = parse_data(read_data)
    end

    ##
    # Return the modified date for a specific user page.
    #
    # @param [String] site  Name of the server.
    # @param [String] user  Name of the user.
    # @return [String] string representation of the datetime.
    # @return [nil] if not found.
    #
    def for_user(site, user)
      result = @data.select do |i|
        i[:site] == site && i[:user] == user
      end.first
      result ? result[:time] : nil
    end

    private

    ##
    # Set up a connection to the remote HTML file.
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
    # Remotely read ~insom's list, using RemoteResource to fetch via HTTP.
    # Save the result to a cache file.
    #
    # If the list has already been scraped today, read from the cached file.
    #
    # @return [Array<String>]
    #   Array of HTML lines that describe a user's updated time.
    #
    def read_data
      filepath = Files.dir_output + 'modified.html'
      if Tildeverse.data.updated_today? && filepath.exist?
        open(filepath).readlines.map(&:chomp).select { |i| i.match('<a href') }
      else
        [].tap do |a|
          a.replace(remote.get.split("\n").select { |i| i.match('<a href') })
          Files.save_array(a, filepath) if Files.dir_output.writable?
        end
      end
    end

    ##
    # Parse ~insom's HTML formatted lines to a usable hash.
    #
    # @param [Array<String>] input_data
    #   Array of HTML lines that describe a user's updated time.
    # @return [Array<Hash{Symbol => String}>]
    #   Array of hashes that describe a user's updated time.
    # @example
    #   [
    #     {
    #       :site => "tilde.town",
    #       :user => "nossidge",
    #       :time => "2017-04-02T07:18:44"
    #     }
    #   ]
    #
    def parse_data(input_data)
      input_data.map do |i|
        i = i.gsub('<br/>', '')
        i = i.gsub('</a>', '')
        i = i.split('>')[1..-1].join
        {
          site: i.split('/')[2],
          user: i.split('/')[3].delete('~'),
          time: i.split(' -- ')[1]
        }
      end
    end
  end
end
