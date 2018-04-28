#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +tilde.works+
    #
    class TildeWorks < Tildeverse::Site
      ##
      # Calls {Tildeverse::Site#initialize} with arg +tilde.works+
      #
      def initialize
        super({
          name: 'tilde.works',
          root: 'http://tilde.works/',
          resource: 'http://tilde.works/',
          url_format_user: 'http://tilde.works/~USER/'
        })
      end

      ##
      # @return [Array<String>] all users of +tilde.works+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # These are the only lines on the page that include '<li><a href'
        members_found = false
        @users = con.result.split("\n").map do |i|
          members_found = true  if i.strip == '<h2>users</h2>'
          members_found = false if i.strip == '</ul>'
          next unless members_found && i =~ /<li><a href/
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
