#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class OfmanytradesCom < TildeSite
    def initialize
      super 'ofmanytrades.com'
    end

    # Manually found 3 users, but no list.
    def users
      %w[ajroach42 djsundog noah]
    end
  end
end

################################################################################
