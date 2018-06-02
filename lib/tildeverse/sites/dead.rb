#!/usr/bin/env ruby

require 'abstract_type'

module Tildeverse
  class Site
    ##
    # Class for Tildeverse sites that are not online
    #
    class Dead < self
      include AbstractType
      abstract_method :scrape_users

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
