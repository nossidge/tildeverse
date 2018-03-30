#!/usr/bin/env ruby

module Tildeverse
  module Site
    ##
    # Site information and user list for +drawbridge.club+
    #
    class DrawbridgeClub < Tildeverse::TildeSite
      ##
      # Calls {Tildeverse::TildeSite#initialize} with arg +drawbridge.club+
      #
      def initialize
        super 'drawbridge.club'
      end

      ##
      # @return [Boolean] the site's known online status.
      #
      def online?
        false
      end

      ##
      # @return [Array<String>] all users of +drawbridge.club+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # These are the only lines on the page that include '<li><a href'
        # 2015/03/05  drawbridge.club merged into tilde.town
        @users = con.result.split("\n").map do |i|
          next unless i =~ /<li><a href/
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
