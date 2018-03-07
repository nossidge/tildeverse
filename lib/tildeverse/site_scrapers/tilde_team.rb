#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class TildeTeam < TildeSite
    def initialize
      super 'tilde.team'
    end

    # These are lines on the page that start with '<h5'.
    def users
      return @users if @users
      return @users = [] if con.error

      @users = con.result.split("\n").map do |i|
        next unless i.strip =~ /^<h5/
        i.split('~').last.split('<').first
      end.compact.sort.uniq
      puts no_user_message if @users.empty?
      @users
    end
  end
end

################################################################################