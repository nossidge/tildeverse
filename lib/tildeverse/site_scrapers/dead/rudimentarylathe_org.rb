#!/usr/bin/env ruby

module Tildeverse
  module Site
    ##
    # Site information and user list for +rudimentarylathe.org+
    #
    class RudimentarylatheOrg < Tildeverse::TildeSite
      ##
      # Calls {Tildeverse::TildeSite#initialize} with arg +rudimentarylathe.org+
      #
      def initialize
        super 'rudimentarylathe.org'
      end

      ##
      # @return [Boolean] the site's known online status.
      #
      def self.online?
        false
      end

      ##
      # @return [Array<String>] all users of +rudimentarylathe.org+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # These are the only lines on the page that include '<li><a href'
        @users = con.result.split("\n").map do |i|
          next unless i =~ /<li><a href/
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
