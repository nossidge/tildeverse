#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +hypertext.website+
    #
    class HypertextWebsite < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +hypertext.website+
      #
      def initialize
        super(
          name: 'hypertext.website',
          url_root: 'http://hypertext.website/',
          url_list: 'http://hypertext.website/',
          homepage_format: 'http://hypertext.website/~USER/'
        )
      end

      ##
      # @return [Array<String>] all users of +hypertext.website+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # These are the only lines on the page that include '<li><a href'
        @users = con.result.split("\n").map do |i|
          next unless i =~ /<li><a href/
          user = i.first_between_two_chars("'").strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
