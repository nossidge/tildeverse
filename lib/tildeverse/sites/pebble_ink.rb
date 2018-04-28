#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +pebble.ink+
    #
    class PebbleInk < Tildeverse::Site
      ##
      # Calls {Tildeverse::Site#initialize} with arg +pebble.ink+
      #
      def initialize
        super({
          name: 'pebble.ink',
          root: 'http://pebble.ink/',
          resource: '',
          url_format_user: 'http://pebble.ink/~USER/'
        })
      end

      ##
      # @return [Array<String>] all users of +pebble.ink+
      #
      def scrape_users
        # Manually found 8 users, but no easily parsable list.
        %w[clach04 contolini elzilrac imt jovan ke7ofi phildini waste]
      end
    end
  end
end
