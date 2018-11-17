#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +botb.club+
    #
    class BotbClub < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +botb.club+
      #
      def initialize
        super TildeSiteURI.new('https://botb.club/')
      end

      ##
      # @return [Array<String>] all users of +botb.club+
      #
      def scrape_users
        validate_usernames do
          #
          # These are the only lines on the page that begin with '<li><a href='
          con.result.split("\n").map do |i|
            next unless i.strip =~ /^<li><a href=/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
