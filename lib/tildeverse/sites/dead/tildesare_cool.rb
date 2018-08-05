#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +tildesare.cool+
    #
    class TildesareCool < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +tildesare.cool+
      #
      def initialize
        super TildeSiteURI.new('http://tildesare.cool/')
      end

      ##
      # @return [Array<String>] all users of +tildesare.cool+
      #
      def scrape_users
        validate_usernames do
          #
          # These are the lines on the page that include '<li><a href'
          con.result.split("\n").map do |i|
            next unless i =~ /<li><a href=/
            user = i.split('a href').last.strip
            user = user.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
