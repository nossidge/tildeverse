#!/usr/bin/env ruby

module Tildeverse
  #
  # A bit different, this one. They don't even use Tildes!
  class RemotesClub < TildeSite
    def initialize
      super 'remotes.club'
    end

    def users
      return @users if @users
      return @users = [] if con.error

      @users = con.result.split("\n").map do |i|
        next unless i =~ /<li data-last-update/
        i.split('href="https://').last.split('.').first
      end.compact.sort.uniq
      puts no_user_message if @users.empty?
      @users
    end
  end
end
