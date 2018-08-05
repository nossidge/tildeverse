#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +tilde.works+
    #
    class TildeWorks < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +tilde.works+
      #
      def initialize
        super TildeSiteURI.new('http://tilde.works/')
      end

      ##
      # @return [Array<String>] all users of +tilde.works+
      #
      def scrape_users
        validate_usernames do
          #
          # These are the only lines on the page that include '<li><a href'
          found = false
          con.result.split("\n").map do |i|
            found = true  if i.strip == '<h2>users</h2>'
            found = false if i.strip == '</ul>'
            next unless found && i =~ /<li><a href/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
