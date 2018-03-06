#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class LosangelesPabloXyz < TildeSite
    def initialize
      super 'losangeles.pablo.xyz'
    end

    # 2015/01/03  New tildebox
    # 2015/01/15  User list on index.html
    # 2015/06/13  RIP
    def users
      return @users if @users
      return @users = [] if con.error

      @users = []
      members_found = false
      con.result.split("\n").each do |i|
        members_found = true if i =~ /<p><b>Users</
        next unless members_found && i =~ /<li>/
        i.split('<li').each do |j|
          j = j.strip.delete('</li')
          @users << j.first_between_two_chars('>') unless j == ''
        end
      end
      puts no_user_message if @users.empty?
      @users
    end
  end
end

################################################################################
