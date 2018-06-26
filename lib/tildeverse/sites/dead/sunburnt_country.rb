#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +sunburnt.country+
    #
    class SunburntCountry < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +sunburnt.country+
      #
      def initialize
        super(
          name: 'sunburnt.country',
          url_root: 'http://sunburnt.country/',
          url_list: 'http://sunburnt.country/~tim/directory.html',
          homepage_format: 'http://sunburnt.country/~USER/'
        )
      end

      ##
      # @return [Array<String>] all users of +sunburnt.country+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # 2015/06/13  RIP
        # Really easy, just read every line of the html.
        @users = con.result.split("\n").map do |i|
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
