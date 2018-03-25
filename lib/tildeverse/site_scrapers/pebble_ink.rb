#!/usr/bin/env ruby

module Tildeverse
  module Site
    #
    # Manually found 8 users, but no easily parsable list.
    class PebbleInk < Tildeverse::TildeSite
      def initialize
        super 'pebble.ink'
      end

      def users
        %w[clach04 contolini elzilrac imt jovan ke7ofi phildini waste]
      end
    end
  end
end
