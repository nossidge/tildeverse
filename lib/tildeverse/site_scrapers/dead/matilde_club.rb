#!/usr/bin/env ruby

module Tildeverse
  module Site
    ##
    # Site information and user list for +matilde.club+
    #
    class MatildeClub < Tildeverse::TildeSite
      ##
      # Calls {Tildeverse::TildeSite#initialize} with arg +matilde.club+
      #
      def initialize
        super 'matilde.club'
      end

      ##
      # @return [Boolean] the site's known online status.
      #
      def online?
        false
      end

      ##
      # @return [Array<String>] all users of +matilde.club+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # This is not newline based, so need to do other stuff.
        # 2016/02/04  RIP
        @users = []
        con.result.split("\n").each do |i|
          next unless i =~ /<ul><li>/
          i.split('</li><li>').each do
            user = i.first_between_two_chars('"').strip
            user = user.remove_trailing_slash.split('~').last.strip
            @users << user
          end
        end
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
