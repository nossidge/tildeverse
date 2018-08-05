#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +tilde.club+
    #
    class TildeClub < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +tilde.club+
      #
      def initialize
        super TildeSiteURI.new('http://tilde.club/')
      end

      ##
      # @return [Array<String>] all users of +tilde.club+
      #
      def scrape_users
        validate_usernames do
          #
          # These are the only lines on the page that begin with '<li>'
          con.result.split("\n").map do |i|
            next unless i =~ /^<li>/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
