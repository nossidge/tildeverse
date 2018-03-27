#!/usr/bin/env ruby

module Tildeverse
  module Site
    ##
    # Site information and user list for +tilde.city+
    #
    class TildeCity < Tildeverse::TildeSite
      ##
      # Calls {Tildeverse::TildeSite#initialize} with arg +tilde.city+
      #
      def initialize
        super 'tilde.city'
      end

      ##
      # @return [Array<String>] all users of +tilde.city+
      #
      def users
        # Manually found 2 users, but no list.
        %w[twilde skk]
      end
    end
  end
end
