#!/usr/bin/env ruby

module Tildeverse
  #
  # These are the lines on the page that include '<li><a href'
  class TildesareCool < TildeSite
    def initialize
      super 'tildesare.cool'
    end

    def users
      return @users if @users
      return @users = [] if con.error?

      @users = con.result.split("\n").map do |i|
        next unless i =~ /<li><a href=/
        user = i.split('a href').last.strip
        user = user.first_between_two_chars('"').strip
        user.remove_trailing_slash.split('~').last.strip
      end.compact.sort.uniq
      puts no_user_message if @users.empty?
      @users
    end
  end
end
