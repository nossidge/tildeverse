#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class TildeWorks < TildeSite
    def initialize
      super 'tilde.works'
    end

    # These are the only lines on the page that include '<li><a href'
    def users
      return @users if @users
      return @users = [] if con.error

      members_found = false
      @users = con.result.split("\n").map do |i|
        members_found = true  if i.strip == '<h2>users</h2>'
        members_found = false if i.strip == '</ul>'
        next unless members_found && i =~ /<li><a href/
        user = i.first_between_two_chars('"').strip
        user.remove_trailing_slash.split('~').last.strip
      end.compact.sort.uniq
      puts no_user_message if @users.empty?
      @users
    end
  end
end

################################################################################
