#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +myrtle-st.club+
    #
    class MyrtleStClub < Tildeverse::Site
      ##
      # Calls {Tildeverse::Site#initialize} with arg +myrtle-st.club+
      #
      def initialize
        super 'myrtle-st.club'
      end

      ##
      # @return [Boolean] the site's known online status.
      #
      def self.online?
        false
      end

      ##
      # @return [Array<String>] all users of +myrtle-st.club+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # These are the lines on the page that include '<p> <a href'
        # 2017/11/24  RIP
        @users = con.result.split("\n").map do |i|
          next unless i =~ /<p> <a href=/
          user = i.split('a href').last.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
