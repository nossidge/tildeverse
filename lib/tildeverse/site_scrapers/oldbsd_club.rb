#!/usr/bin/env ruby

module Tildeverse
  module Site
    #
    # No idea about this one.
    class OldbsdClub < Tildeverse::TildeSite
      def initialize
        super 'oldbsd.club'
      end

      def users
        []
      end
    end
  end
end
