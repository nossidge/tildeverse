#!/usr/bin/env ruby

module Tildeverse
  class Site
    ##
    # Class for Tildeverse sites that are online
    #
    class Live < self
      ##
      # Abstract method, to be implemented by inheritors
      # @raise [NotImplementedError]
      #
      def scrape_users
        msg = "Abstract method '##{__method__}' " \
              'not implemented at this level of inheritance'
        raise NotImplementedError, msg
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
