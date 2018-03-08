#!/usr/bin/env ruby

module Tildeverse
  #
  # There's a strange issue with curling this URL.
  # I'll just use a manual list for now.
  class YourtildeCom < TildeSite
    def initialize
      super 'yourtilde.com'
    end

    def users
      %w[WL01 deepend emv jovan kingofobsolete login mhj msmcmickey
         mushmouth nozy sebboh ubergeek]
    end
  end
end
