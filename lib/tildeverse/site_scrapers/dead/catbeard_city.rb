#!/usr/bin/env ruby

module Tildeverse
  module Site
    ##
    # Site information and user list for +catbeard.city+
    #
    class CatbeardCity < Tildeverse::TildeSite
      ##
      # Calls {Tildeverse::TildeSite#initialize} with arg +catbeard.city+
      #
      def initialize
        super 'catbeard.city'
      end

      ##
      # @return [Array<String>] all users of +catbeard.city+
      #
      def users
        return @users if @users
        return @users = [] if con.error?

        # These are lines on the page that include '<li><a href'
        # But only between two other lines.
        # 2015/10/26  RIP
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
end
