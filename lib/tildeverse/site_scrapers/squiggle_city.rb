#!/usr/bin/env ruby

module Tildeverse
  #
  # The JSON doesn't include all the users.
  # So group them together, sort and uniq.
  class SquiggleCity < TildeSite
    def initialize
      super 'squiggle.city'
    end

    def users
      return @users if @users
      a = read_json
      b = read_html
      @users = a.concat(b).sort.uniq
    end

    # JSON format. There's a NULL record at the end of the file though.
    # Also, doesn't seem to include all users...
    def read_json
      url = 'https://squiggle.city/tilde.json'
      return [] if con(url).error?

      parsed = JSON[con(url).result.delete("\t")]
      users = parsed['users'].map do |i|
        i['username']
      end.compact.sort.uniq
      puts no_user_message if users.empty?
      users
    end

    # These are the only lines on the page that include '<tr><td><a href'
    def read_html
      url = 'https://squiggle.city/'
      return [] if con(url).error?

      users = con(url).result.split("\n").map do |i|
        next unless i =~ /<tr><td><a href/
        user = i.first_between_two_chars('"').strip
        user.remove_trailing_slash.split('~').last.strip
      end.compact.sort.uniq
      puts no_user_message if users.empty?
      users
    end
  end
end
