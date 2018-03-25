#!/usr/bin/env ruby

module Tildeverse
  module Site
    #
    # 2015/01/03  New box, a nice easy JSON format.
    # 2016/01/13  RIP
    class Club6Nl < Tildeverse::TildeSite
      def initialize
        super 'club6.nl'
      end

      def users
        return @users if @users
        return @users = [] if con.error?

        parsed = JSON[con.result.delete("\t")]
        @users = parsed['users'].map do |i|
          i['username']
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
