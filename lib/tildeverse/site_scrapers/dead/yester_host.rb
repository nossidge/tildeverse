#!/usr/bin/env ruby

module Tildeverse
  #
  # 2015/06/13  RIP
  class YesterHost < TildeSite
    def initialize
      super 'yester.host'
    end

    def users
      return @users if @users
      a = read_json
      b = read_html
      @users = a.concat(b).sort.uniq
    end

    # JSON format. There's a NULL record at the end of the file though.
    def read_json
      url = 'http://yester.host/tilde.json'
      return [] if con(url).error?

      parsed = JSON[con(url).result.delete("\t")]
      users = parsed['users'].map do |i|
        i['username']
      end.compact.sort.uniq
      puts no_user_message if users.empty?
      users
    end

    # These are the only lines on the page that include '<li><a href'
    def read_html
      url = 'http://yester.host/'
      return [] if con(url).error?

      users = con.result.split("\n").map do |i|
        next unless i =~ /<li><a href/
        user = i.first_between_two_chars('"').strip
        user.remove_trailing_slash.split('~').last.strip
      end.compact.sort.uniq
      puts no_user_message if users.empty?
      users
    end
  end
end
