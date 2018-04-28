#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +retronet.net+
    #
    class RetronetNet < Tildeverse::Site
      ##
      # Calls {Tildeverse::Site#initialize} with arg +retronet.net+
      #
      def initialize
        super({
          name: 'retronet.net',
          root: 'http://retronet.net/',
          resource: 'http://retronet.net/users.html',
          url_format_user: 'http://retronet.net/~USER/'
        })
      end

      ##
      # @return [Boolean] the site's known online status.
      #
      def self.online?
        false
      end

      ##
      # @return [Array<String>] all users of +retronet.net+
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
