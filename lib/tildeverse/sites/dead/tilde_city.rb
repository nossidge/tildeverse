#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +tilde.city+
    #
    class TildeCity < Tildeverse::Site::Dead
      ##
      # Calls {Tildeverse::Site#initialize} with arg +tilde.city+
      #
      def initialize
        super({
          name: 'tilde.city',
          root: 'http://tilde.city/',
          resource: '',
          url_format_user: 'http://tilde.city/~USER/'
        })
      end

      ##
      # @return [Array<String>] all users of +tilde.city+
      #
      def scrape_users
        # Manually found 2 users, but no list.
        %w[twilde skk]
      end
    end
  end
end
