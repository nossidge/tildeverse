#!/usr/bin/env ruby

module Tildeverse
  #
  # These are lines on the page that include '<li><a href',
  #   after the line that matches '<p>Current users:</p>'
  class HackersCool < TildeSite
    def initialize
      super 'hackers.cool'
    end

    def users
      return @users if @users
      return @users = [] if con.error?

      # There's an error with some URLs, so we need to use the anchor text.
      members_found = false
      @users = con.result.split("\n").map do |i|
        members_found = true if i.strip == '<p>Current users:</p>'
        next unless members_found && i =~ /<li><a href/
        i.split('~').last.split('<').first.strip
      end.compact.sort.uniq
      puts no_user_message if @users.empty?
      @users
    end
  end
end
