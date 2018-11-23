#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  class Site
    ##
    # Class for Tildeverse sites that are not online
    #
    class Dead < self
      ##
      # (see Site#scrape_users)
      #
      def scrape_users
        raise Error::AbstractMethodError, __method__
      end

      ##
      # @return [false] the site's known online status
      #
      def self.online?
        false
      end
    end
  end
end

# Require all files in the 'dead' subdirectory
Dir["#{__dir__}/dead/*.rb"].each { |f| require f }
