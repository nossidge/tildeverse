#!/usr/bin/env ruby

module Tildeverse
  ##
  # Scrape modified dates from ~insom's list,
  # http://tilde.town/~insom/modified.html.
  class ModifiedDates
    ##
    # Remotely read ~insom's list, using RemoteResource to fetch via HTTP.
    #
    # @return [Array<Hash{Symbol => String}>]
    #   Array of hashes that describe a user's updated time.
    #   Example element:
    #   - +:site+ [String] "tilde.town"
    #   - +:user+ [String] "nossidge"
    #   - +:time+ [String] "2017-04-02T07:18:44"
    #
    def get
      return @results if @results
      info = [
        'insom/modified',
        'http://tilde.town/~insom/',
        'http://tilde.town/~insom/modified.html'
      ]
      remote = RemoteResource.new(*info)
      lines = remote.get.split("\n").select { |i| i.match('<a href') }
      @results = lines.map do |i|
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
