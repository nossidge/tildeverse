#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +ctrl-c.club+
    #
    class CtrlCClub < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +ctrl-c.club+
      #
      def initialize
        super TildeSiteURI.new('http://ctrl-c.club/tilde.json')
      end

      ##
      # @return [Array<String>] all users of +ctrl-c.club+
      #
      def scrape_users
        validate_usernames do
          #
          # Current as of 2015/11/13
          # Uses a nice JSON format.
          parsed = JSON[con.result.delete("\t")]
          parsed['users'].map do |i|
            i['username']
          end.compact.sort.uniq
        end
      end
    end
  end
end
