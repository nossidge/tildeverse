#!/usr/bin/env ruby

module Tildeverse
  #
  # These are the only lines on the page that include '<li><a href'
  # 2015/03/05  RIP
  class GermantilDe < TildeSite
    def initialize
      super 'germantil.de'
    end

    def users
      return @users if @users
      return @users = [] if con.error

      @users = con.result.split("\n").map do |i|
        next unless i =~ /<li><a href/
        user = i.first_between_two_chars('"').strip
        user.remove_trailing_slash.split('~').last.strip
      end.compact.sort.uniq
      puts no_user_message if @users.empty?
      @users
    end
  end
end
