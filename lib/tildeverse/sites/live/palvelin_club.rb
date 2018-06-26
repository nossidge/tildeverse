#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +palvelin.club+
    #
    class PalvelinClub < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +palvelin.club+
      #
      def initialize
        super(
          name: 'palvelin.club',
          url_root: 'http://palvelin.club/',
          url_list: 'http://palvelin.club/users.html',
          homepage_format: 'http://palvelin.club/~USER/'
        )
      end

      ##
      # @return [Array<String>] all users of +palvelin.club+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # These are the only lines on the page that begin with '<li>'
        # This is very hacky, but it fixes the string encoding problem.
        @users = con.result[89..-1].split("\n").map do |i|
          next unless i =~ /^<li>/
          i.first_between_two_chars('"').split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
