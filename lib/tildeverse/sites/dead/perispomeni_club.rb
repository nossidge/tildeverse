#!/usr/bin/env ruby

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
        # These are the lines on the page that begin with '<li>'
        # But only after the line '<h2>users</h2>' and before '</ul>'
        members_found = false
        @users = con.result.split("\n").map do |i|
          members_found = true  if i =~ %r{<h2>users</h2>}
          members_found = false if i =~ %r{</ul>}
          next unless members_found && i =~ /<li/
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
