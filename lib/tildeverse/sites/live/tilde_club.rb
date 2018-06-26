#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +tilde.club+
    #
    class TildeClub < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +tilde.club+
      #
      def initialize
        super(
          name: 'tilde.club',
          url_root: 'http://tilde.club/',
          url_list: 'http://tilde.club/',
          homepage_format: 'http://tilde.club/~USER/'
        )
      end

      ##
      # @return [Array<String>] all users of +tilde.club+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # These are the only lines on the page that begin with '<li>'
        @users = con.result.split("\n").map do |i|
          next unless i =~ /^<li>/
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
