#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +tilde.team+
    #
    class TildeTeam < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +tilde.team+
      #
      def initialize
        super({
          name: 'tilde.team',
          root: 'https://tilde.team/',
          resource: 'https://tilde.team/',
          url_format_user: 'https://tilde.team/~USER/'
        })
      end

      ##
      # @return [Array<String>] all users of +tilde.team+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # These are lines on the page that start with '<h5'.
        @users = con.result.split("\n").map do |i|
          next unless i.strip =~ /^<h5/
          i.split('~').last.split('<').first
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
