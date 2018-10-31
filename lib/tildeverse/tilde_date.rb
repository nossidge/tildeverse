#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'

module Tildeverse
  ##
  # Date object that is optimised for its usage in Tildeverse User objects.
  # Can be used in all contexts as +Date+ objects, but {#to_s} is slightly
  # different.
  #
  # Dates that are read as +-+ from the input file are set to the Unix Epoch,
  # +1970-01-01+. They can be used as dates with that value, and will return +-+
  # on {#to_s} so that they can be written back to the file or console.
  #
  class TildeDate < Date
    ##
    # Date to use to signify that the value is 'not defined'
    #
    EPOCH = Date.new(1970, 1, 1)

    ##
    # String value to return when a date is 'not defined'
    #
    EMPTY = '-'

    ##
    # Convert down to a normal Ruby +Date+ object
    #
    # @return [Date]
    #
    def to_date
      Date.new(year, month, day)
    end

    ##
    # Return a String representation of the date, in the form +YYYY-MM-DD+.
    # But, return +-+ if the date is the same as the Unix Epoch +1970-01-01+
    #
    # @return [String]
    #
    def to_s
      return EMPTY if self == EPOCH
      super
    end

    class << self

      ##
      # Convert an input into a {TildeDate} object.
      # If the input already responds to {#to_date}, then use that date.
      # If the input is +-+, use the Date of the Unix Epoch.
      # Else, apply +input#to_s+ and send to +Date#parse+
      #
      # @param [Date, String] input
      # @return [TildeDate]
      #
      def new(input)
        d = parse(input)
        super(d.year, d.month, d.day)
      end

      ##
      # Convert an input into a +Date+ object.
      # If the input already responds to {#to_date}, then return it unchanged.
      # If the input is +-+, return the Date of the Unix Epoch.
      # Else, apply +input#to_s+ and send to +Date#parse+
      #
      # @param [Date, String] input
      # @return [Date]
      #
      def parse(input)
        return input if input.respond_to?(:to_date)
        return EPOCH if input.to_s == EMPTY
        super(input.to_s)
      end
    end
  end
end
