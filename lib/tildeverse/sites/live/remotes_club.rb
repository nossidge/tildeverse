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
        uri = TildeSiteURI.new('https://www.remotes.club/')
        uri.homepage_format = 'https://USER.remotes.club/'
        super uri
      end

      ##
      # @return [Array<String>] all users of +remotes.club+
      #
      def scrape_users
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
