#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +tildecow.com+
    #
    class TildecowCom < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +tildecow.com+
      #
      def initialize
        super TildeSiteURI.new('http://www.tildecow.com/')
      end

      ##
      # @return [Array<String>] all users of +tildecow.com+
      #
      def scrape_users
        validate_usernames do
          #
          # These are lines on the page that include '<a href',
          # after the line that matches 'Visit our members' WWW pages'
          found = false
          con.result.split("\n").map do |i|
            found = true  if i =~ /Visit our members' WWW pages/
            next unless found && i =~ /<a href/
            i.first_between_two_chars('"').split('/')[3]
          end.compact.sort.uniq
        end
      end
    end
  end
end
