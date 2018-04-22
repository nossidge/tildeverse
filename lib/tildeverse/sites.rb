#!/usr/bin/env ruby

# Require all files in the subdirectory with the same name as this file.
Dir["#{__FILE__.rpartition('.rb').first}/*.rb"].each { |file| require file }

module Tildeverse
  ##
  # Namespace for site classes.
  #
  # Each Tildeverse site has its own class, with custom user scraping.
  #
  module Sites
    ##
    # Find all Tilde site classes by returning the inheritors of {Site}.
    #
    # @return [Array<Class>]
    #
    def self.classes
      ObjectSpace.each_object(Class).select do |i|
        i < Tildeverse::Site
      end.sort_by(&:name)
    end
  end
end
