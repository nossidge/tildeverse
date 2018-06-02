#!/usr/bin/env ruby

module Tildeverse
  ##
  # Namespace for site classes.
  #
  # Each Tildeverse site has its own class, with custom user scraping.
  #
  module Sites
    ##
    # Find all Tilde site classes by returning the inheritors of {Site::Live}
    # and {Site::Dead}.
    #
    # @return [Array<Class>]
    #
    def self.classes
      ObjectSpace.each_object(Class).select do |i|
        i < Site::Live || i < Site::Dead
      end.sort_by(&:name)
    end
  end
end

# Require all files in the 'sites' subdirectory
Dir["#{__dir__}/sites/*.rb"].each { |f| require f }
