#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class TildeCity < TildeSite
    def initialize
      super 'tilde.city'
    end

    # Manually found 2 users, but no list.
    def users
      %w[twilde skk]
    end
  end
end

################################################################################
