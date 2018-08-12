#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +ofmanytrades.com+
    #
    class OfmanytradesCom < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +ofmanytrades.com+
      #
      def initialize
        super TildeSiteURI.new('https://ofmanytrades.com/')
      end

      ##
      # @return [Array<String>] all users of +ofmanytrades.com+
      #
      def scrape_users
        #
        # Manually found some users, but no list.
        %w[ajroach42 djsundog noah russ]
      end
    end
  end
end
