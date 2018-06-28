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
        super TildeSiteURI.new('http://hypertext.website/')
      end

      ##
      # @return [Array<String>] all users of +hypertext.website+
      #
      def scrape_users
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
