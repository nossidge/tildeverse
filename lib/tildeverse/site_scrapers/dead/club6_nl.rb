#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class Club6Nl < TildeSite
    def initialize
      super 'club6.nl'
    end

    # 2015/01/03  New box, a nice easy JSON format.
    # 2016/01/13  RIP
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
