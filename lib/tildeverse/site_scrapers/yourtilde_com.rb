#!/usr/bin/env ruby

################################################################################

module Tildeverse
  class YourtildeCom < TildeSite
    def initialize
      super 'yourtilde.com'
    end

    # There's a strange issue with curling this URL.
    # I'll just use a manual list for now.
    def users
      %w[WL01 deepend emv jovan kingofobsolete login mhj msmcmickey
         mushmouth nozy sebboh ubergeek]
    end
  end
end

################################################################################
