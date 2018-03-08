#!/usr/bin/env ruby

module Tildeverse
  #
  # Manually found 2 users, but no list.
  class TildeCity < TildeSite
    def initialize
      super 'tilde.city'
    end

    def users
      %w[twilde skk]
    end
  end
end
