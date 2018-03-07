#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class TildeClub < TildeSite
    def initialize
      super 'tilde.club'
    end

    # These are the only lines on the page that begin with '<li>'
    def users
      return @users if @users
      return @users = [] if con.error

      @users = con.result.split("\n").map do |i|
        next unless i =~ /^<li>/
        user = i.first_between_two_chars('"').strip
        user.remove_trailing_slash.split('~').last.strip
      end.compact.sort.uniq
      puts no_user_message if @users.empty?
      @users
    end
  end
end

################################################################################