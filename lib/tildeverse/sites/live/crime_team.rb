#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +crime.team+
    #
    class CrimeTeam < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +crime.team+
      #
      def initialize
        super TildeSiteURI.new('https://crime.team/')
      end

      ##
      # @return [Array<String>] all users of +crime.team+
      #
      def scrape_users
        validate_usernames do
          #
          # 2017/04/11  New box, user list on index.html
          con.result.split("\n").map do |i|
            next unless i.strip =~ /^<li>/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
