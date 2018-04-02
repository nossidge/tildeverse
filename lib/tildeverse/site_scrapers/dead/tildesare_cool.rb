#!/usr/bin/env ruby

module Tildeverse
  module Site
    ##
    # Site information and user list for +tildesare.cool+
    #
    class TildesareCool < Tildeverse::TildeSite
      ##
      # Calls {Tildeverse::TildeSite#initialize} with arg +tildesare.cool+
      #
      def initialize
        super 'tildesare.cool'
      end

      ##
      # @return [Boolean] the site's known online status.
      #
      def self.online?
        false
      end

      ##
      # @return [Array<String>] all users of +tildesare.cool+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # These are the lines on the page that include '<li><a href'
        @users = con.result.split("\n").map do |i|
          next unless i =~ /<li><a href=/
          user = i.split('a href').last.strip
          user = user.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
