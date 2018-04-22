#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +oldbsd.club+
    #
    class OldbsdClub < Tildeverse::Site
      ##
      # Calls {Tildeverse::Site#initialize} with arg +oldbsd.club+
      #
      def initialize
        super 'oldbsd.club'
      end

      ##
      # @return [Boolean] the site's known online status.
      #
      def self.online?
        false
      end

      ##
      # @return [Array<String>] all users of +oldbsd.club+
      #
      def scrape_users
        # No idea about this one.
        []
      end
    end
  end
end
