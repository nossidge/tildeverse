#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +backtick.town+
    #
    class BacktickTown < Tildeverse::Site::Live
      ##
      # Calls {Tildeverse::Site#initialize} with arg +backtick.town+
      #
      def initialize
        super(
          name: 'backtick.town',
          url_root: 'https://backtick.town/',
          url_list: '',
          homepage_format: 'https://backtick.town/~USER/'
        )
      end

      ##
      # @return [Array<String>] all users of +backtick.town+
      #
      def scrape_users
        # Manually found 8 users, but no list.
        %w[alyssa j jay nk kc nickolas360 nix tb10]
      end
    end
  end
end
