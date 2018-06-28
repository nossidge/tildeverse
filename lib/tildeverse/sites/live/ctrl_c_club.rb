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
        # Current as of 2015/11/13
        # Uses a nice JSON format.
        parsed = JSON[con.result.delete("\t")]
        @users = parsed['users'].map do |i|
          i['username']
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
