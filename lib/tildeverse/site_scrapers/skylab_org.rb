#!/usr/bin/env ruby

module Tildeverse
  module Site
    #
    # These are the only lines on the page that include '<a href'
    class SkylabOrg < Tildeverse::TildeSite
      def initialize
        super 'skylab.org'
      end

      def users
        return @users if @users
        return @users = [] if con.error?

        members_found = false
        @users = con.result.split("\n").map do |i|
          members_found = true  if i =~ /Personal homepages on skylab.org/
          members_found = false if i =~ /Close Userlist/
          next unless members_found && i =~ /<li><a href/
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
