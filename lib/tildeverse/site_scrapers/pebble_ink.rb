#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class PebbleInk < TildeSite
    def initialize
      super 'pebble.ink'
    end

    # Manually found 8 users, but no easily parsable list.
    def users
      %w[clach04 contolini elzilrac imt jovan ke7ofi phildini waste]
    end
  end
end

################################################################################
