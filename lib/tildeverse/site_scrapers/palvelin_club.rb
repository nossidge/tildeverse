#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class PalvelinClub < TildeSite
    def initialize
      super 'palvelin.club'
    end

    # These are the only lines on the page that begin with '<li>'
    def users
      return @users if @users
      return @users = [] if con.error

      # This is very hacky, but it fixes the string encoding problem.
      @users = con.result[89..-1].split("\n").map do |i|
        next unless i =~ /^<li>/
        i.first_between_two_chars('"').split('~').last.strip
      end.compact.sort.uniq
      puts no_user_message if @users.empty?
      @users
    end
  end
end

################################################################################
