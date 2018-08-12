#!/usr/bin/env ruby
# frozen_string_literal: true

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
        super TildeSiteURI.new('http://riotgirl.club/~jspc/tc.result.html')
      end

      ##
      # @return [Array<String>] all users of +riotgirl.club+
      #
      def scrape_users
        validate_usernames do
          #
          # These are the only lines on the page that include '<a href'
          # 2017/11/24  RIP
          con.result.split("\n").map do |i|
            next unless i =~ /<a href/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
