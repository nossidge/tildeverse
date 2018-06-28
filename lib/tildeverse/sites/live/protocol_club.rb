#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +protocol.club+
    #
    class ProtocolClub < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +protocol.club+
      #
      def initialize
        super TildeSiteURI.new('http://protocol.club/~insom/protocol.24h.html')
      end

      ##
      # @return [Array<String>] all users of +protocol.club+
      #
      def scrape_users
        # The https has expired, do use http.
        @users = con.result.split("\n").map do |i|
          next unless i =~ /^<li>/
          user = i.split('href=')[1].first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
