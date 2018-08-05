#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +squiggle.city+
    #
    class SquiggleCity < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +squiggle.city+
      #
      def initialize
        super TildeSiteURI.new('https://squiggle.city/tilde.json')
      end

      ##
      # @return [Array<String>] all users of +squiggle.city+
      #
      def scrape_users
        # The JSON doesn't include all the users.
        # So group them together, sort and uniq.
        a = read_json
        b = read_html
        a.concat(b).sort.uniq
      end

      ##
      # @return [Array<String>] users from the JSON source.
      #
      def read_json
        url = 'https://squiggle.city/tilde.json'
        return [] if con(url).error?

        validate_usernames do
          #
          # There's a NULL record at the end of the file.
          # Also, doesn't seem to include all users...
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
        url = 'https://squiggle.city/'
        return [] if con(url).error?

        validate_usernames do
          #
          # These are the only lines on the page that include '<tr><td><a href'
          con(url).result.split("\n").map do |i|
            next unless i =~ /<tr><td><a href/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
