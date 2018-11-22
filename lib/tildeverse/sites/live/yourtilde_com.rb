#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +yourtilde.com+
    #
    # @note This site has a few URL aliases:
    #   - +yourtilde.com+
    #   - +tildecities.com+
    #   - +retrodigital.net+
    #
    class YourtildeCom < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +yourtilde.com+
      #
      def initialize
        super TildeSiteURI.new('https://yourtilde.com/userlist.html')
      end

      ##
      # @return [Array<String>] all users of +yourtilde.com+
      #
      def scrape_users
        #
        # There's a strange issue with curling this URL.
        # I'll just use a manual list for now.
        %w[
          anizawa arung asvvvad ben biglysmalls brendantcc caleb copart
          deepend distip diverger edwardthefma emv envican fosslinux geoff
          hustler hyperboredoubt jovan juaniman99 khuxkm kingofobsolete
          login mhj msmcmickey mspe mushmouth nozy oak_tree petegozz rileyjb
          rofopaje rostovripper sebboh silbern slip snowdusk tiasum tomasino
          tunas ubergeek valdebrick wl01 worldwide xdrixxyz zenoil zin
        ]
      end

      private

      ##
      # HTTP requests from tilde.town to yourtilde.com fail for some reason,
      # so don't check for 'con.error?' on the URI.
      #
      def scrape_users_cache
        scrape_users
      end

      ##
      # Here's the scraper code, in case the curl issue is ever fixed:
      #
      def actual_scraper_code
        validate_usernames do
          #
          # These are lines on the page that start with '<a href'.
          con.result.split("\n").map do |i|
            next unless i.strip =~ /^<a href/
            i.split('~').last.split('<').first
          end.compact.sort.uniq
        end
      end
    end
  end
end
