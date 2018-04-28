#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +totallynuclear.club+
    #
    class TotallynuclearClub < Tildeverse::Site
      ##
      # Calls {Tildeverse::Site#initialize} with arg +totallynuclear.club+
      #
      def initialize
        super({
          name: 'totallynuclear.club',
          root: 'http://totallynuclear.club/',
          resource: 'http://totallynuclear.club/',
          url_format_user: 'http://totallynuclear.club/~USER/'
        })
      end

      ##
      # @return [Boolean] the site's known online status.
      #
      def self.online?
        false
      end

      ##
      # @return [Array<String>] all users of +totallynuclear.club+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # These are the only lines on the page that begin with '<li>'
        @users = con.result.split("\n").map do |i|
          if i =~ /^<li>/
            user = i.first_between_two_chars('"').remove_trailing_slash
            user.split('~').last.strip
          end
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
