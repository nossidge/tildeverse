#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +yourtilde.com+
    #
    class YourtildeCom < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +yourtilde.com+
      #
      def initialize
        super(
          name: 'yourtilde.com',
          url_root: 'https://yourtilde.com/',
          url_list: 'https://yourtilde.com/userlist.html',
          homepage_format: 'https://yourtilde.com/~USER/'
        )
      end

      ##
      # @return [Array<String>] all users of +yourtilde.com+
      #
      def scrape_users
        # There's a strange issue with curling this URL.
        # I'll just use a manual list for now.
        @users = %w[
          Hustler WL01 caleb copart deepend diverger emv hyperboredoubt
          jovan khuxkm kingofobsolete login mhj msmcmickey mushmouth
          nozy oak_tree sebboh ubergeek zenoil
        ]
      end

      private

      ##
      # Here's the scraper code, in case the curl issue is ever fixed:
      #
      def actual_scraper_code
        return @users if @users
        return @users = [] if con.error?

        # These are lines on the page that start with '<a href'.
        @users = con.result.split("\n").map do |i|
          next unless i.strip =~ /^<a href/
          i.split('~').last.split('<').first
        end.compact.sort.uniq
        puts no_user_message if @users.empty?
        @users
      end
    end
  end
end
