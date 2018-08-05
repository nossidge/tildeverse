#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +noiseandsignal.com+
    #
    class NoiseandsignalCom < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +noiseandsignal.com+
      #
      def initialize
        super TildeSiteURI.new('http://noiseandsignal.com/')
      end

      ##
      # @return [Array<String>] all users of +noiseandsignal.com+
      #
      def scrape_users
        validate_usernames do
          #
          # These are the lines on the page that begin with '<li>'
          # But only after the line '<div class="row" id="members">'
          # and before '</ul>'
          found = false
          con.result.split("\n").map do |i|
            found = true  if i =~ /<div class="row" id="members">/
            found = false if i =~ %r{</ul>}
            next unless found && i =~ /<li/
            user = i.first_between_two_chars('"').strip
            user.remove_trailing_slash.split('~').last.strip
          end.compact.sort.uniq
        end
      end
    end
  end
end
