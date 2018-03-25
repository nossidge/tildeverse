#!/usr/bin/env ruby

module Tildeverse
  module Site
    #
    # Manually found 3 users, but no list.
    class OfmanytradesCom < Tildeverse::TildeSite
      def initialize
        super 'ofmanytrades.com'
      end

      def users
        %w[ajroach42 djsundog noah]
      end
    end
  end
end
