#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +ofmanytrades.com+
    #
    class OfmanytradesCom < Tildeverse::Site
      ##
      # Calls {Tildeverse::Site#initialize} with arg +ofmanytrades.com+
      #
      def initialize
        super 'ofmanytrades.com'
      end

      ##
      # @return [Array<String>] all users of +ofmanytrades.com+
      #
      def scrape_users
        # Manually found 3 users, but no list.
        %w[ajroach42 djsundog noah]
      end
    end
  end
end