#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +remotes.club+
    #
    class RemotesClub < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +remotes.club+
      #
      def initialize
        super({
          name: 'remotes.club',
          root: 'https://www.remotes.club/',
          resource: 'https://www.remotes.club/',
          url_format_user: 'https://USER.remotes.club/'
        })
      end

      ##
      # @return [Array<String>] all users of +remotes.club+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # A bit different, this one. They don't even use Tildes!
        @users = con.result.split("\n").map do |i|
          next unless i =~ /<li data-last-update/
          i.split('href="https://').last.split('.').first
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
