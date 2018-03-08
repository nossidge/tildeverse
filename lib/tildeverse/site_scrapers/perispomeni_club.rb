#!/usr/bin/env ruby

module Tildeverse
  #
  # These are the lines on the page that begin with '<li>'
  # But only after the line '<h2>users</h2>' and before '</ul>'
  class PerispomeniClub < TildeSite
    def initialize
      super 'perispomeni.club'
    end

    def users
      return @users if @users
      return @users = [] if con.error

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
