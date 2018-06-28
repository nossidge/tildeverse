#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +totallynuclear.club+
    #
    class TotallynuclearClub < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +totallynuclear.club+
      #
      def initialize
        super TildeSiteURI.new('http://totallynuclear.club/')
      end

      ##
      # @return [Array<String>] all users of +totallynuclear.club+
      #
      def scrape_users
        # These are the only lines on the page that begin with '<li>'
        @users = con.result.split("\n").map do |i|
          if i =~ /^<li>/
            user = i.first_between_two_chars('"').remove_trailing_slash
            user.split('~').last.strip
          end
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
