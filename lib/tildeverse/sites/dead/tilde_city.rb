#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +tilde.city+
    #
    class TildeCity < Tildeverse::Site
      ##
      # Calls {Tildeverse::Site#initialize} with arg +tilde.city+
      #
      def initialize
        super 'tilde.city'
      end

      ##
      # @return [Boolean] the site's known online status.
      #
      def self.online?
        false
      end

      ##
      # @return [Array<String>] all users of +tilde.city+
      #
      def scrape_users
        # Manually found 2 users, but no list.
        %w[twilde skk]
      end
    end
  end
end