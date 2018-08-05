#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +catbeard.city+
    #
    class CatbeardCity < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +catbeard.city+
      #
      def initialize
        super TildeSiteURI.new('http://catbeard.city/')
      end

      ##
      # @return [Array<String>] all users of +catbeard.city+
      #
      def scrape_users
        validate_usernames do
          #
          # These are lines on the page that include '<li><a href'
          # But only between two other lines.
          # 2015/10/26  RIP
          found = false
          con.result.split("\n").map do |i|
            found = true  if i =~ /<p>Current inhabitants:</
            found = false if i =~ /<h2>Pages Changed In Last 24 Hours</
            next unless found && i =~ /<li><a href/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
