#!/usr/bin/env ruby

module Tildeverse
  module Site
    #
    # The https has expired, do use http.
    class ProtocolClub < Tildeverse::TildeSite
      def initialize
        super 'protocol.club'
      end

      def users
        return @users if @users
        return @users = [] if con.error?

        @users = con.result.split("\n").map do |i|
          next unless i =~ /^<li>/
          user = i.split('href=')[1].first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
