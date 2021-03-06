#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +palvelin.club+
    #
    class PalvelinClub < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +palvelin.club+
      #
      def initialize
        super TildeSiteURI.new('http://palvelin.club/users.html')
      end

      ##
      # @return [Array<String>] all users of +palvelin.club+
      #
      def scrape_users
        validate_usernames do
          #
          # These are the only lines on the page that begin with '<li>'
          # This is very hacky, but it fixes the string encoding problem
          con.result[89..-1].split("\n").map do |i|
            next unless i =~ /^<li>/
            i.first_between_two_chars('"').split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
