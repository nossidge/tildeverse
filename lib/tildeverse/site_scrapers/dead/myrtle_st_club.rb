#!/usr/bin/env ruby

module Tildeverse
  module Site
    ##
    # Site information and user list for +myrtle-st.club+
    #
    class MyrtleStClub < Tildeverse::TildeSite
      ##
      # Calls {Tildeverse::TildeSite#initialize} with arg +myrtle-st.club+
      #
      def initialize
        super 'myrtle-st.club'
      end

      ##
      # @return [Array<String>] all users of +myrtle-st.club+
      #
      def users
        return @users if @users
        return @users = [] if con.error?

        # These are the lines on the page that include '<p> <a href'
        # 2017/11/24  RIP
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
