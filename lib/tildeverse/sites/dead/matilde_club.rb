#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +matilde.club+
    #
    class MatildeClub < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +matilde.club+
      #
      def initialize
        super TildeSiteURI.new('http://matilde.club/~mikker/users.html')
      end

      ##
      # @return [Array<String>] all users of +matilde.club+
      #
      def scrape_users
        validate_usernames do
          #
          # This is not newline based, so need to do other stuff.
          # 2016/02/04  RIP
          [].tap do |users|
            con.result.split("\n").each do |i|
              next unless i =~ /<ul><li>/
              i.split('</li><li>').each do
                user = i.first_between_two_chars('"').strip
                user = user.remove_trailing_slash.split('~').last.strip
                users << user
              end
            end
          end
        end
      end
    end
  end
end
