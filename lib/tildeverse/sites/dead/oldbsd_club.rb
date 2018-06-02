#!/usr/bin/env ruby

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
        super({
          name: 'oldbsd.club',
          root: 'http://oldbsd.club/',
          resource: '',
          url_format_user: ''
        })
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
