#!/usr/bin/env ruby

module Tildeverse
  module Site
    #
    # Manually found 2 users, but no list.
    class TildeCity < Tildeverse::TildeSite
      def initialize
        super 'tilde.city'
      end

      def users
        %w[twilde skk]
      end
    end
  end
end
