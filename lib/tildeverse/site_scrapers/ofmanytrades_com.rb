#!/usr/bin/env ruby

module Tildeverse
  module Site
    ##
    # Site information and user list for +ofmanytrades.com+
    #
    class OfmanytradesCom < Tildeverse::TildeSite
      ##
      # Calls {Tildeverse::TildeSite#initialize} with arg +ofmanytrades.com+
      #
      def initialize
        super 'ofmanytrades.com'
      end

      ##
      # @return [Array<String>] all users of +ofmanytrades.com+
      #
      def users
        # Manually found 3 users, but no list.
        %w[ajroach42 djsundog noah]
      end
    end
  end
end
