#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +club6.nl+
    #
    class Club6Nl < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +club6.nl+
      #
      def initialize
        super TildeSiteURI.new('https://club6.nl/tilde.json')
      end

      ##
      # @return [Array<String>] all users of +club6.nl+
      #
      def scrape_users
        validate_usernames do
          #
          # 2015/01/03  New box, a nice easy JSON format.
          # 2016/01/13  RIP
          parsed = JSON[con.result.delete("\t")]
          parsed['users'].map do |i|
            i['username']
          end.compact.sort.uniq
        end
      end
    end
  end
end
