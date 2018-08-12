#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +tilde.red+
    #
    class TildeRed < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +tilde.red+
      #
      def initialize
        super TildeSiteURI.new('https://tilde.red/')
      end

      ##
      # @return [Array<String>] all users of +tilde.red+
      #
      def scrape_users
        validate_usernames do
          #
          # These are the only lines on the page that begin with '<li>'
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
