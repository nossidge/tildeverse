#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +tilde.center+
    #
    class TildeCenter < Tildeverse::Site
      ##
      # Calls {Tildeverse::Site#initialize} with arg +tilde.center+
      #
      def initialize
        super 'tilde.center'
      end

      ##
      # @return [Boolean] the site's known online status.
      #
      def self.online?
        false
      end

      ##
      # @return [Array<String>] all users of +tilde.center+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # These are the only lines on the page that begin with '<li>'
        @users = con.result.split("\n").map do |i|
          next unless i =~ /^<li/
          user = i.split('a href').last.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
