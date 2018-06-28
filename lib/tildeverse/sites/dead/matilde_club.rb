#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +matilde.club+
    #
    class MatildeClub < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +matilde.club+
      #
      def initialize
        super TildeSiteURI.new('http://matilde.club/~mikker/users.html')
      end

      ##
      # @return [Array<String>] all users of +matilde.club+
      #
      def scrape_users
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
