#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +backtick.town+
    #
    class BacktickTown < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +backtick.town+
      #
      def initialize
        super TildeSiteURI.new('https://backtick.town/')
      end

      ##
      # @return [Array<String>] all users of +backtick.town+
      #
      def scrape_users
        #
        # Manually found 8 users, but no list.
        %w[alyssa j jay nk kc nickolas360 nix tb10]
      end
    end
  end
end
