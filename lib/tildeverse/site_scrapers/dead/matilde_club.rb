#!/usr/bin/env ruby

module Tildeverse
  #
  # This is not newline based, so need to do other stuff.
  # 2016/02/04  RIP
  class MatildeClub < TildeSite
    def initialize
      super 'matilde.club'
    end

    def users
      return @users if @users
      return @users = [] if con.error

      @users = []
      con.result.split("\n").each do |i|
        next unless i =~ /<ul><li>/
        i.split('</li><li>').each do
          user = i.first_between_two_chars('"').strip
          user = user.remove_trailing_slash.split('~').last.strip
          @users << user
        end
      end
      puts no_user_message if @users.empty?
      @users
    end
  end
end
