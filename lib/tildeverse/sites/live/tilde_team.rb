#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +tilde.team+
    #
    class TildeTeam < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +tilde.team+
      #
      def initialize
        super TildeSiteURI.new('https://tilde.team/')
      end

      ##
      # @return [Array<String>] all users of +tilde.team+
      #
      def scrape_users
        validate_usernames do
          #
          # These are lines on the page that start with '<h5'.
          con.result.split("\n").map do |i|
            next unless i.strip =~ /^<h5/
            i.split('~').last.split('<').first
          end.compact.sort.uniq
        end
      end
    end
  end
end
