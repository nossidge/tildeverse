#!/usr/bin/env ruby

module Tildeverse
  module Site
    ##
    # Site information and user list for +club6.nl+
    #
    class Club6Nl < Tildeverse::TildeSite
      ##
      # Calls {Tildeverse::TildeSite#initialize} with arg +club6.nl+
      #
      def initialize
        super 'club6.nl'
      end

      ##
      # @return [Array<String>] all users of +club6.nl+
      #
      def users
        return @users if @users
        return @users = [] if con.error?

        # 2015/01/03  New box, a nice easy JSON format.
        # 2016/01/13  RIP
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
