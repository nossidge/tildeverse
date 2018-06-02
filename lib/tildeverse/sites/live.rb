#!/usr/bin/env ruby

require 'abstract_type'

module Tildeverse
  class Site
    ##
    # Class for Tildeverse sites that are online
    #
    class Live < self
      include AbstractType
      abstract_method :scrape_users

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
