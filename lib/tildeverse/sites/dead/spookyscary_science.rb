#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +spookyscary.science+
    #
    class SpookyscaryScience < Tildeverse::Site
      ##
      # Calls {Tildeverse::Site#initialize} with arg +spookyscary.science+
      #
      def initialize
        super 'spookyscary.science'
      end

      ##
      # @return [Boolean] the site's known online status.
      #
      def self.online?
        false
      end

      ##
      # @return [Array<String>] all users of +spookyscary.science+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # 2016/08/10  New box
        # 2016/11/04  Okay, something weird is going on here. Every page but
        #             the index reverts to root. I guess consider it dead?
        #             For now just use cached users. But keep a watch on it.
        # 2017/09/04  RIP
        @users = con.result.split("\n").map do |i|
          next unless i =~ /^<a href/
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end

      ##
      # @return [Array<String>] cached users of +spookyscary.science+
      #
      def cache
        %w[_vax aerandir arthursucks deuslapis
           drip roob spiff sternalrub wanderingmind]
      end
    end
  end
end
