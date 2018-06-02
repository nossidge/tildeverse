#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +drawbridge.club+
    #
    class DrawbridgeClub < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +drawbridge.club+
      #
      def initialize
        super({
          name: 'drawbridge.club',
          root: 'http://drawbridge.club/',
          resource: 'http://drawbridge.club/',
          url_format_user: 'http://drawbridge.club/~USER/'
        })
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
