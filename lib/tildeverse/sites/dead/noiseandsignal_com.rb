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
        super(
          name: 'noiseandsignal.com',
          url_root: 'http://noiseandsignal.com/',
          url_list: 'http://noiseandsignal.com/',
          homepage_format: 'http://noiseandsignal.com/~USER/'
        )
      end

      ##
      # @return [Array<String>] all users of +noiseandsignal.com+
      #
      def scrape_users
        return @users if @users
        return @users = [] if con.error?

        # These are the lines on the page that begin with '<li>'
        # But only after the line '<div class="row" id="members">'
        # and before '</ul>'
        members_found = false
        @users = con.result.split("\n").map do |i|
          members_found = true  if i =~ /<div class="row" id="members">/
          members_found = false if i =~ %r{</ul>}
          next unless members_found && i =~ /<li/
          user = i.first_between_two_chars('"').strip
          user.remove_trailing_slash.split('~').last.strip
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
