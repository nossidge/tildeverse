#!/usr/bin/env ruby

module Tildeverse
  module Site
    ##
    # Site information and user list for +riotgirl.club+
    #
    class RiotgirlClub < Tildeverse::TildeSite
      ##
      # Calls {Tildeverse::TildeSite#initialize} with arg +riotgirl.club+
      #
      def initialize
        super 'riotgirl.club'
      end

      ##
      # @return [Array<String>] all users of +riotgirl.club+
      #
      def users
        return @users if @users
        return @users = [] if con.error?

        # These are the only lines on the page that include '<a href'
        # 2017/11/24  RIP
        @users = con.result.split("\n").map do |i|
          next unless i =~ /<a href/
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
