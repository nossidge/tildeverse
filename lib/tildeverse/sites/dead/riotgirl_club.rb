#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +riotgirl.club+
    #
    class RiotgirlClub < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +riotgirl.club+
      #
      def initialize
        super(
          name: 'riotgirl.club',
          url_root: 'http://riotgirl.club',
          url_list: 'http://riotgirl.club/~jspc/tc.result.html',
          homepage_format: 'http://riotgirl.club/~USER/'
        )
      end

      ##
      # @return [Array<String>] all users of +riotgirl.club+
      #
      def scrape_users
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
