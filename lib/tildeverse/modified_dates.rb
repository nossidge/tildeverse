#!/usr/bin/env ruby

module Tildeverse
  #
  # Scrape modified dates from ~insom's list.
  class ModifiedDates
    def get
      return @results if @results
      info = [
        'insom/modified',
        'http://tilde.town/~insom/',
        'http://tilde.town/~insom/modified.html'
      ]
      tc = TildeConnection.new(*info)
      lines = tc.get.split("\n").select { |i| i.match('<a href') }
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
