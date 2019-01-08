#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  module Sites
    ##
    # Site information and user list for +oldbsd.club+
    #
    class OldbsdClub < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +oldbsd.club+
      #
      def initialize
        super TildeSiteURI.new('http://oldbsd.club/')
      end

      ##
      # @return [Array<String>] all users of +oldbsd.club+
      #
      def scrape_users
        #
        # No idea about this one
        []
      end
    end
  end
end
