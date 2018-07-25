#!/usr/bin/env ruby

module Tildeverse
  class Site
    ##
    # Class for Tildeverse sites that are not online
    #
    class Dead < self
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
