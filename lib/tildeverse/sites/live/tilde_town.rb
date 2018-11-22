#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +tilde.town+
    #
    class TildeTown < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +tilde.town+
      #
      def initialize
        super TildeSiteURI.new('https://tilde.town/~dan/users.json')
      end

      ##
      # @return [Array<String>] all users of +tilde.town+
      #
      def scrape_users
        # 2016/08/05  JSON is incomplete, so merge with index.html user list
        a = read_json
        b = read_html
        a.concat(b).sort.uniq
      end

      ##
      # @return [Array<String>] users from the JSON source.
      #
      def read_json
        url = 'http://tilde.town/~dan/users.json'
        return [] if con(url).error?

        validate_usernames do
          #
          # A nice easy JSON format.
          parsed = JSON[con(url).result.delete("\t")]
          parsed.map(&:first).compact.sort.uniq
        end
      end

      ##
      # @return [Array<String>] users from the HTML source.
      #
      def read_html
        url = 'http://tilde.town/'
        return [] if con(url).error?

        validate_usernames do
          #
          # These are the lines on the page that include 'a href'
          # But only after the line '<sub>sorted by recent changes</sub>'
          # and before the closing '</ul>'
          found = false
          con(url).result.split("\n").map do |i|
            found = true  if i =~ %r{<sub>sorted by recent changes</sub>}
            found = false if i =~ %r{</ul>}
            next unless found && i =~ /a href/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
