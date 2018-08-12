#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +myrtle-st.club+
    #
    class MyrtleStClub < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +myrtle-st.club+
      #
      def initialize
        super TildeSiteURI.new('http://myrtle-st.club/')
      end

      ##
      # @return [Array<String>] all users of +myrtle-st.club+
      #
      def scrape_users
        validate_usernames do
          #
          # These are the lines on the page that include '<p> <a href'
          # 2017/11/24  RIP
          con.result.split("\n").map do |i|
            next unless i =~ /<p> <a href=/
            user = i.split('a href').last.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
