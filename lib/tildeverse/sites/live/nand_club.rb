#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +nand.club+
    #
    class NandClub < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +nand.club+
      #
      def initialize
        super TildeSiteURI.new('http://nand.club/')
      end

      ##
      # @return [Array<String>] all users of +nand.club+
      #
      def scrape_users
        validate_usernames do
          #
          # These are the only lines on the page that begin with '<a href'
          con.result.split("\n").map(&:strip).map do |i|
            next unless i =~ /^<a href/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
