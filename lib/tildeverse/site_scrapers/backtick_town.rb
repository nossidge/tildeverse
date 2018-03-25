#!/usr/bin/env ruby

module Tildeverse
  module Site
    #
    # Manually found 8 users, but no list.
    class BacktickTown < Tildeverse::TildeSite
      def initialize
        super 'backtick.town'
      end

      def users
        %w[alyssa j jay nk kc nickolas360 nix tb10]
      end
    end
  end
end
