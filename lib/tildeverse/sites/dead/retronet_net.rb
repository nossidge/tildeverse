#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +retronet.net+
    #
    class RetronetNet < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +retronet.net+
      #
      def initialize
        super TildeSiteURI.new('http://retronet.net/users.html')
      end

      ##
      # @return [Array<String>] all users of +retronet.net+
      #
      def scrape_users
        validate_usernames do
          #
          # These are the only lines on the page that include '<li><a href'
          con.result.split("\n").map do |i|
            next unless i =~ /<li><a href/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
