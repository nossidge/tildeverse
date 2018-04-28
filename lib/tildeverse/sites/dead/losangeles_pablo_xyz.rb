#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +losangeles.pablo.xyz+
    #
    class LosangelesPabloXyz < Tildeverse::Site
      ##
      # Calls {Tildeverse::Site#initialize} with arg +losangeles.pablo.xyz+
      #
      def initialize
        super({
          name: 'losangeles.pablo.xyz',
          root: 'http://losangeles.pablo.xyz',
          resource: 'http://losangeles.pablo.xyz',
          url_format_user: 'http://losangeles.pablo.xyz/~USER/'
        })
      end

      ##
      # @return [Boolean] the site's known online status.
      #
      def self.online?
        false
      end

      ##
      # @return [Array<String>] all users of +losangeles.pablo.xyz+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # 2015/01/03  New tildebox
        # 2015/01/15  User list on index.html
        # 2015/06/13  RIP
        @users = []
        members_found = false
        con.result.split("\n").each do |i|
          members_found = true if i =~ /<p><b>Users</
          next unless members_found && i =~ /<li>/
          i.split('<li').each do |j|
            j = j.strip.delete('</li')
            @users << j.first_between_two_chars('>') unless j == ''
          end
        end
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
