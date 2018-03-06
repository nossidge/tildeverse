#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class CatbeardCity < TildeSite
    def initialize
      super 'catbeard.city'
    end

    # These are lines on the page that include '<li><a href'
    # But only between two other lines.
    # 2015/10/26  RIP
    def users
      return @users if @users
      return @users = [] if con.error

      members_found = false
      @users = con.result.split("\n").map do |i|
        members_found = true  if i =~ /<p>Current inhabitants:</
        members_found = false if i =~ /<h2>Pages Changed In Last 24 Hours</
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
