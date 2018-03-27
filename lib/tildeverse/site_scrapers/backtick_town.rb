#!/usr/bin/env ruby

module Tildeverse
  module Site
    ##
    # Site information and user list for +backtick.town+
    #
    class BacktickTown < Tildeverse::TildeSite
      ##
      # Calls {Tildeverse::TildeSite#initialize} with arg +backtick.town+
      #
      def initialize
        super 'backtick.town'
      end

      ##
      # @return [Array<String>] all users of +backtick.town+
      #
      def users
        # Manually found 8 users, but no list.
        %w[alyssa j jay nk kc nickolas360 nix tb10]
      end
    end
  end
end
