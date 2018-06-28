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
        @users = a.concat(b).sort.uniq
      end

      ##
      # @return [Array<String>] users from the JSON source.
      #
      def read_json
        url = 'https://squiggle.city/tilde.json'
        return [] if con(url).error?

        # There's a NULL record at the end of the file.
        # Also, doesn't seem to include all users...
        parsed = JSON[con(url).result.delete("\t")]
        users = parsed['users'].map do |i|
          i['username']
        end.compact.sort.uniq
        puts no_user_message if users.empty?
        users
      end

      ##
      # @return [Array<String>] users from the HTML source.
      #
      def read_html
        url = 'https://squiggle.city/'
        return [] if con(url).error?

        # These are the only lines on the page that include '<tr><td><a href'
        users = con(url).result.split("\n").map do |i|
          next unless i =~ /<tr><td><a href/
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if users.empty?
        users
      end
    end
  end
end
