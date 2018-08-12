#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +yester.host+
    #
    class YesterHost < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +yester.host+
      #
      def initialize
        super TildeSiteURI.new('http://yester.host/tilde.json')
      end

      ##
      # @return [Array<String>] all users of +yester.host+
      #
      def scrape_users
        #
        # 2015/06/13  RIP
        a = read_json
        b = read_html
        a.concat(b).sort.uniq
      end

      ##
      # @return [Array<String>] users from the JSON source.
      #
      def read_json
        url = 'http://yester.host/tilde.json'
        return [] if con(url).error?

        validate_usernames do
          #
          # There's a NULL record at the end of the file.
          parsed = JSON[con(url).result.delete("\t")]
          parsed['users'].map do |i|
            i['username']
          end.compact.sort.uniq
        end
      end

      ##
      # @return [Array<String>] users from the HTML source.
      #
      def read_html
        url = 'http://yester.host/'
        return [] if con(url).error?

        validate_usernames do
          #
          # These are the only lines on the page that include '<li><a href'
          con.result.split("\n").map do |i|
            next unless i =~ /<li><a href/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
