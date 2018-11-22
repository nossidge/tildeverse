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
          # These are the lines that contain '<a href="/~'
          needle = '<a href="/~'
          con.result.split("\n").map do |i|
            next unless i.include?(needle)
            i.split(needle).last.split('/').first
          end.compact.sort.uniq
        end
      end
    end
  end
end
