#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +pebble.ink+
    #
    class PebbleInk < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +pebble.ink+
      #
      def initialize
        super TildeSiteURI.new('http://pebble.ink/')
      end

      ##
      # @return [Array<String>] all users of +pebble.ink+
      #
      def scrape_users
        #
        # Manually found 8 users, but no easily parsable list
        %w[clach04 contolini elzilrac imt jovan ke7ofi phildini waste]
      end
    end
  end
end
