#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +rudimentarylathe.org+
    #
    class RudimentarylatheOrg < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +rudimentarylathe.org+
      #
      def initialize
        super({
          name: 'rudimentarylathe.org',
          root: 'http://rudimentarylathe.org/',
          resource: 'http://rudimentarylathe.org/',
          url_format_user: 'http://rudimentarylathe.org/~USER/'
        })
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
