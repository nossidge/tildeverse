#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +tilde.red+
    #
    class TildeRed < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +tilde.red+
      #
      def initialize
        super(
          name: 'tilde.red',
          url_root: 'https://tilde.red/',
          url_list: 'https://tilde.red/',
          homepage_format: 'https://tilde.red/~USER/'
        )
      end

      ##
      # @return [Array<String>] all users of +tilde.red+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # These are the only lines on the page that begin with '<li>'
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
