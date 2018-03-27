#!/usr/bin/env ruby

module Tildeverse
  module Site
    ##
    # Site information and user list for +yourtilde.com+
    #
    class YourtildeCom < Tildeverse::TildeSite
      ##
      # Calls {Tildeverse::TildeSite#initialize} with arg +yourtilde.com+
      #
      def initialize
        super 'yourtilde.com'
      end

      ##
      # @return [Array<String>] all users of +yourtilde.com+
      #
      def users
        # There's a strange issue with curling this URL.
        # I'll just use a manual list for now.
        %w[WL01 deepend emv jovan kingofobsolete login mhj msmcmickey
           mushmouth nozy sebboh ubergeek]
      end
    end
  end
end
