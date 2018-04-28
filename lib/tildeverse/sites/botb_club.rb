#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +botb.club+
    #
    class BotbClub < Tildeverse::Site
      ##
      # Calls {Tildeverse::Site#initialize} with arg +botb.club+
      #
      def initialize
        super({
          name: 'botb.club',
          root: 'https://botb.club/',
          resource: 'https://botb.club/',
          url_format_user: 'https://botb.club/~USER/'
        })
      end

      ##
      # @return [Array<String>] all users of +botb.club+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # These are the only lines on the page that begin with '<li><a href='
        @users = con.result.split("\n").map do |i|
          next unless i.strip =~ /^<li><a href=/
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
