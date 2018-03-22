#!/usr/bin/env ruby

module Tildeverse
  #
  # 2017/04/11  New box, user list on index.html
  class CrimeTeam < TildeSite
    def initialize
      super 'crime.team'
    end

    def users
      return @users if @users
      return @users = [] if con.error?

      @users = con.result.split("\n").map do |i|
        next unless i.strip =~ /^<li>/
        user = i.first_between_two_chars('"').strip
        user.remove_trailing_slash.split('~').last.strip
      end.compact.sort.uniq
      puts no_user_message if @users.empty?
      @users
    end
  end
end
