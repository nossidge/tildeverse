#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +perispomeni.club+
    #
    class PerispomeniClub < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +perispomeni.club+
      #
      def initialize
        super TildeSiteURI.new('http://perispomeni.club/')
      end

      ##
      # @return [Array<String>] all users of +perispomeni.club+
      #
      def scrape_users
        validate_usernames do
          #
          # These are the lines on the page that begin with '<li>'
          # But only after the line '<h2>users</h2>' and before '</ul>'
          found = false
          con.result.split("\n").map do |i|
            found = true  if i =~ %r{<h2>users</h2>}
            found = false if i =~ %r{</ul>}
            next unless found && i =~ /<li/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
