#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  ##
  # Class to decorate {Array} with tag-specific validation.
  # Validation ensures that no tag can be added without it being
  # on the list of valid tags.
  # This validation can be disabled if necessary.
  # Once initialised, these objects are immutable.
  #
  # There is one special input tag, +-+.
  # Tags that are read as +-+ from the input file are set to an empty array.
  #
  class TagArray < SimpleDelegator
    class << self
      ##
      # Merge any number of TagArray objects into one.
      # Does NOT do any validation; it is assumed that since the TagArray
      # objects were created without error then they are valid.
      #
      # @param *tag_arrays [Array<TagArray>]
      #   any number of TagArray values
      #
      def merge(*tag_arrays)
        TagArray.new(tag_arrays, validation: false)
      end
    end

    ##
    # String value to return when tag array is empty
    #
    EMPTY = '-'

    ##
    # @param *args [Array<String>]
    #   any number of tag values
    # @param validation [Boolean]
    #   validate tags based on a lookup list
    # @raise [Error::InvalidTags]
    #   if any tag is not valid (if validation is specified)
    #
    def initialize(*args, validation: true)
      tag_array = [*args].flatten.compact.map(&:to_s).sort.uniq
      tag_array -= [EMPTY]
      dodgy_tags = validation ? invalid_tags(tag_array) : []
      raise Error::InvalidTags, dodgy_tags unless dodgy_tags.empty?
      super tag_array.freeze
    end

    ##
    # Return a String representation of the array, delimited by commas.
    # But, return +-+ if the array is empty
    #
    # @return [String]
    #
    def to_s
      empty? ? EMPTY : join(',')
    end

    private

    ##
    # Return an array of the tags that are not valid
    #
    # @param tag_array [Array<String>] tags to validate
    # @return [Array<String>] array of invalid tags
    #
    def invalid_tags(tag_array)
      tag_array - valid_tags
    end

    ##
    # @return [Array<String>] array of valid tags
    #
    def valid_tags
      %w[
        empty brief redirect links blog poetry prose art photo audio
        video gaming tutorial app code procgen web1.0 unix tilde
      ]
    end
  end
end
