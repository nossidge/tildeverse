#!/usr/bin/env ruby

module Tildeverse
  module Site
    #
    # These are the lines on the page that include '<p> <a href'
    # 2017/11/24  RIP
    class MyrtleStClub < Tildeverse::TildeSite
      def initialize
        super 'myrtle-st.club'
      end

      def users
        return @users if @users
        return @users = [] if con.error?

        @users = con.result.split("\n").map do |i|
          next unless i =~ /<p> <a href=/
          user = i.split('a href').last.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
