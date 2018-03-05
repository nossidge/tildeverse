#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class BacktickTown < TildeSite
    def initialize
      super 'backtick.town'
    end

    # Manually found 8 users, but no list.
    def users
      %w[alyssa j jay nk kc nickolas360 nix tb10]
    end
  end
end

################################################################################
