#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +remotes.club+
    #
    class RemotesClub < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +remotes.club+
      #
      def initialize
        uri = TildeSiteURI.new('https://www.remotes.club/')
        uri.homepage_format = 'https://USER.remotes.club/'
        super uri
      end

      ##
      # @return [Array<String>] all users of +remotes.club+
      #
      def scrape_users
        validate_usernames do
          #
          # A bit different, this one. They don't even use Tildes!
          con.result.split("\n").map do |i|
            next unless i =~ /<li data-last-update/
            i.split('href="https://').last.split('.').first
          end.compact.sort.uniq
        end
      end
    end
  end
end
