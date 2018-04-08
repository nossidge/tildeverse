#!/usr/bin/env ruby

module Tildeverse
  ##
  # Namespace for site classes.
  #
  # Each Tildeverse site has its own class, with custom user scraping.
  #
  module Site
    ##
    # Find all Tilde site classes by returning the inheritors of {TildeSite}.
    #
    # @return [Array<Class>]
    #
    def self.classes
      ObjectSpace.each_object(Class).select do |i|
        i < Tildeverse::TildeSite
      end.sort_by(&:name)
    end
  end
end
