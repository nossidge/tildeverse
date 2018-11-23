#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  class Site
    ##
    # Class for Tildeverse sites that are online
    #
    class Live < self
      ##
      # (see Site#scrape_users)
      #
      def scrape_users
        raise Error::AbstractMethodError, __method__
      end

      ##
      # @return [true] the site's known online status
      #
      def self.online?
        true
      end
    end
  end
end

# Require all files in the 'live' subdirectory
Dir["#{__dir__}/live/*.rb"].each { |f| require f }
