#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +skylab.org+
    #
    # @note This site serves different content for HTTPS and HTTP.
    #   The Tildeverse homepages are only available through HTTP.
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
        validate_usernames do
          #
          # These are the only lines on the page that include '<a href'
          found = false
          con.result.split("\n").map do |i|
            found = true  if i =~ /Personal homepages on skylab.org/
            found = false if i =~ /Close Userlist/
            next unless found && i =~ /<li><a href/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
