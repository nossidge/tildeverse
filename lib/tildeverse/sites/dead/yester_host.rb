#!/usr/bin/env ruby

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
        super(
          name: 'yester.host',
          url_root: 'http://yester.host/',
          url_list: 'http://yester.host/tilde.json',
          homepage_format: 'http://yester.host/~USER/'
        )
      end

      ##
      # @return [Array<String>] all users of +yester.host+
      #
      def scrape_users
        # 2015/06/13  RIP
        return @users if @users
        a = read_json
        b = read_html
        @users = a.concat(b).sort.uniq
      end

      ##
      # @return [Array<String>] users from the JSON source.
      #
      def read_json
        url = 'http://yester.host/tilde.json'
        return [] if con(url).error?

        # There's a NULL record at the end of the file.
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
        url = 'http://yester.host/'
        return [] if con(url).error?

        # These are the only lines on the page that include '<li><a href'
        users = con.result.split("\n").map do |i|
          next unless i =~ /<li><a href/
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if users.empty?
        users
      end
    end
  end
end
