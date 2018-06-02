#!/usr/bin/env ruby

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
        super({
          name: 'tilde.town',
          root: 'https://tilde.town/',
          resource: 'http://tilde.town/~dan/users.json',
          url_format_user: 'https://tilde.town/~USER/'
        })
      end

      ##
      # @return [Array<String>] all users of +tilde.town+
      #
      def scrape_users
        # 2016/08/05  JSON is incomplete, so merge with index.html user list
        return @users if @users
        a = read_json
        b = read_html
        @users = a.concat(b).sort.uniq
      end

      ##
      # @return [Array<String>] users from the JSON source.
      #
      def read_json
        url = 'http://tilde.town/~dan/users.json'
        return [] if con(url).error?

        # A nice easy JSON format.
        parsed = JSON[con(url).result.delete("\t")]
        users = parsed.map(&:first).compact.sort.uniq
        puts no_user_message if users.empty?
        users
      end

      ##
      # @return [Array<String>] users from the HTML source.
      #
      def read_html
        url = 'http://tilde.town/'
        return [] if con(url).error?

        # These are the lines on the page that include 'a href'
        # But only after the line '<sub>sorted by recent changes</sub>'
        # and before the closing '</ul>'
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
