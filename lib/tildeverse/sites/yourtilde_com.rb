#!/usr/bin/env ruby

module Tildeverse
  module Sites
    ##
    # Site information and user list for +yourtilde.com+
    #
    class YourtildeCom < Tildeverse::Site
      ##
      # Calls {Tildeverse::Site#initialize} with arg +yourtilde.com+
      #
      def initialize
        super 'yourtilde.com'
      end

      ##
      # @return [Array<String>] all users of +yourtilde.com+
      #
      def scrape_users
        # There's a strange issue with curling this URL.
        # I'll just use a manual list for now.
        %w[WL01 deepend emv jovan kingofobsolete login mhj msmcmickey
           mushmouth nozy sebboh ubergeek]
      end
    end
  end
end
