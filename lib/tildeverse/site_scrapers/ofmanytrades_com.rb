#!/usr/bin/env ruby

module Tildeverse
  #
  # Manually found 3 users, but no list.
  class OfmanytradesCom < TildeSite
    def initialize
      super 'ofmanytrades.com'
    end

    def users
      %w[ajroach42 djsundog noah]
    end
  end
end
