#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class CtrlCClub < TildeSite
    def initialize
      super 'ctrl-c.club'
    end

    # Current as of 2015/11/13
    # Uses a nice JSON format.
    def users
      return @users if @users
      return @users = [] if con.error

      parsed = JSON[con.result.delete("\t")]
      @users = parsed['users'].map do |i|
        i['username']
      end.compact.sort.uniq
      puts no_user_message if @users.empty?
      @users
    end
  end
end

################################################################################
