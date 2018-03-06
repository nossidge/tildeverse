#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class SpookyscaryScience < TildeSite
    def initialize
      super 'spookyscary.science'
    end

    # 2016/08/10  New box
    # 2016/11/04  Okay, something weird is going on here. Every page but the
    #             index reverts to root. I guess consider it dead?
    #             For now just use cached users. But keep a watch on it.
    # 2017/09/04  RIP
    def users
      return @users if @users
      return @users = [] if con.error

      @users = con.result.split("\n").map do |i|
        next unless i =~ /^<a href/
        user = i.first_between_two_chars('"').strip
        user.remove_trailing_slash.split('~').last.strip
      end.compact.sort.uniq
      puts no_user_message if @users.empty?
      @users
    end

    def cache
      %w[_vax aerandir arthursucks deuslapis
         drip roob spiff sternalrub wanderingmind]
    end
  end
end

################################################################################
