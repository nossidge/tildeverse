#!/usr/bin/env ruby

module Tildeverse
  #
  # This is straight from someone's ~user index.html.
  # I'm betting this will be the first page to break.
  # 2015/10/26  RIP
  class BleepbloopClub < TildeSite
    def initialize
      super 'bleepbloop.club'
    end

    def users
      return @users if @users
      return @users = [] if con.error?

      @users = con.result.split("\n").map do |i|
        next unless i =~ /<li>/
        user = i.first_between_two_chars('"').strip
        user.remove_trailing_slash.split('~').last.strip
      end.compact.sort.uniq
      puts no_user_message if @users.empty?
      @users
    end
  end
end
