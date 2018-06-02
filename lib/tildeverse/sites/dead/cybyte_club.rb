#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +cybyte.club+
    #
    class CybyteClub < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +cybyte.club+
      #
      def initialize
        super({
          name: 'cybyte.club',
          root: 'http://cybyte.club/',
          resource: 'http://cybyte.club/',
          url_format_user: 'http://cybyte.club/~USER/'
        })
      end

      ##
      # @return [Array<String>] all users of +cybyte.club+
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
