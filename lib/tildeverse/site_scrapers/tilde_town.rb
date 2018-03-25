#!/usr/bin/env ruby

module Tildeverse
  module Site
    #
    # 2016/08/05  JSON is incomplete, so merge with index.html user list
    class TildeTown < Tildeverse::TildeSite
      def initialize
        super 'tilde.town'
      end

      def users
        return @users if @users
        a = read_json
        b = read_html
        @users = a.concat(b).sort.uniq
      end

      # A nice easy JSON format.
      def read_json
        url = 'http://tilde.town/~dan/users.json'
        return [] if con(url).error?

        parsed = JSON[con(url).result.delete("\t")]
        users = parsed.map(&:first).compact.sort.uniq
        puts no_user_message if users.empty?
        users
      end

      # These are the lines on the page that include 'a href'
      # But only after the line '<sub>sorted by recent changes</sub>'
      # and before the closing '</ul>'
      def read_html
        url = 'http://tilde.town/'
        return [] if con(url).error?

        members_found = false
        users = con(url).result.split("\n").map do |i|
          members_found = true  if i =~ %r{<sub>sorted by recent changes</sub>}
          members_found = false if i =~ %r{</ul>}
          next unless members_found && i =~ /a href/
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if users.empty?
        users
      end
    end
  end
end
