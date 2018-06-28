#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +skylab.org+
    #
    class SkylabOrg < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +skylab.org+
      #
      def initialize
        super TildeSiteURI.new('http://skylab.org/')
      end

      ##
      # @return [Array<String>] all users of +skylab.org+
      #
      def scrape_users
        # These are the only lines on the page that include '<a href'
        members_found = false
        @users = con.result.split("\n").map do |i|
          members_found = true  if i =~ /Personal homepages on skylab.org/
          members_found = false if i =~ /Close Userlist/
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
