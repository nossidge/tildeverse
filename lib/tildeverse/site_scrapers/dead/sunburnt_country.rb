#!/usr/bin/env ruby

module Tildeverse
  #
  # 2015/06/13  RIP
  # Really easy, just read every line of the html.
  class SunburntCountry < TildeSite
    def initialize
      super 'sunburnt.country'
    end

    def users
      return @users if @users
      return @users = [] if con.error

      @users = con.result.split("\n").map do |i|
        user = i.first_between_two_chars('"').strip
        user.remove_trailing_slash.split('~').last.strip
      end.compact.sort.uniq
      puts no_user_message if @users.empty?
      @users
    end
  end
end
