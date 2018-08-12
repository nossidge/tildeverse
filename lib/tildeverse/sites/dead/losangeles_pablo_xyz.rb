#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +losangeles.pablo.xyz+
    #
    class LosangelesPabloXyz < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +losangeles.pablo.xyz+
      #
      def initialize
        super TildeSiteURI.new('http://losangeles.pablo.xyz')
      end

      ##
      # @return [Array<String>] all users of +losangeles.pablo.xyz+
      #
      def scrape_users
        validate_usernames do
          #
          # 2015/01/03  New tildebox
          # 2015/01/15  User list on index.html
          # 2015/06/13  RIP
          [].tap do |users|
            found = false
            con.result.split("\n").each do |i|
              found = true if i =~ /<p><b>Users</
              next unless found && i =~ /<li>/
              i.split('<li').each do |j|
                j = j.strip.delete('</li')
                users << j.first_between_two_chars('>') unless j == ''
              end
            end
          end
        end
      end
    end
  end
end
