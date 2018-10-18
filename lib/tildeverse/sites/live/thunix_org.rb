#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +thunix.org+
    #
    class ThunixOrg < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +thunix.org+
      #
      def initialize
        super TildeSiteURI.new('https://www.thunix.org')
      end

      ##
      # @return [Array<String>] all users of +thunix.org+
      #
      def scrape_users
        validate_usernames do
          (['hexhaxtron'] + find_li + find_a_href).sort.uniq
        end
      end

      private

      # These are the only lines on the page that begin with '<li>'
      def find_li
        con.result.split("\n").map do |i|
          next unless i =~ /^<li>/
          user = i.split('href').last.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
      end

      # These are the only lines on the page that begin with '<a href="~'
      def find_a_href
        con.result.split("\n").map do |i|
          next unless i =~ /^<a href="~/
          user = i.split('a href').last.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
      end
    end
  end
end
