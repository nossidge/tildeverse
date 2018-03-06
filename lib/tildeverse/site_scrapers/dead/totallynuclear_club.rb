#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class TotallynuclearClub < TildeSite
    def initialize
      super 'totallynuclear.club'
    end

    # These are the only lines on the page that begin with '<li>'
    def users
      return @users if @users
      return @users = [] if con.error

      @users = con.result.split("\n").map do |i|
        if i =~ /^<li>/
          user = i.first_between_two_chars('"').remove_trailing_slash
          user.split('~').last.strip
        end
      end.compact.sort.uniq
      puts no_user_message if @users.empty?
      @users
    end
  end
end

################################################################################
