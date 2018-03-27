#!/usr/bin/env ruby

module Tildeverse
  module Site
    ##
    # Site information and user list for +pebble.ink+
    #
    class PebbleInk < Tildeverse::TildeSite
      ##
      # Calls {Tildeverse::TildeSite#initialize} with arg +pebble.ink+
      #
      def initialize
        super 'pebble.ink'
      end

      ##
      # @return [Array<String>] all users of +pebble.ink+
      #
      def users
        # Manually found 8 users, but no easily parsable list.
        %w[clach04 contolini elzilrac imt jovan ke7ofi phildini waste]
      end
    end
  end
end
