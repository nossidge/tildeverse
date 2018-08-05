#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +spookyscary.science+
    #
    class SpookyscaryScience < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +spookyscary.science+
      #
      def initialize
        super TildeSiteURI.new('https://spookyscary.science/~')
      end

      ##
      # @return [Array<String>] all users of +spookyscary.science+
      #
      def scrape_users
        validate_usernames do
          #
          # 2016/08/10  New box
          # 2016/11/04  Okay, something weird is going on here. Every page but
          #             the index reverts to root. I guess consider it dead?
          #             For now just use cached users. But keep a watch on it.
          # 2017/09/04  RIP
          con.result.split("\n").map do |i|
            next unless i =~ /^<a href/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
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
