#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +bleepbloop.club+
    #
    class BleepbloopClub < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +bleepbloop.club+
      #
      def initialize
        super TildeSiteURI.new('https://bleepbloop.club/~eos/')
      end

      ##
      # @return [Array<String>] all users of +bleepbloop.club+
      #
      def scrape_users
        # This is straight from someone's ~user index.html.
        # I'm betting this will be the first page to break.
        # 2015/10/26  RIP
        @users = con.result.split("\n").map do |i|
          next unless i =~ /<li>/
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
