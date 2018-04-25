#!/usr/bin/env ruby

module Tildeverse
  ##
  # Class for reading from and writing to files with data in rows
  # of whitespace-separated values.
  #
  class WSV
    ##
    # @return [Pathname, String] Location of input file
    #
    attr_reader :filepath

    ##
    # @param [Pathname, String] filepath Location of input file
    #
    def initialize(filepath)
      @filepath = filepath
    end

    ##
    # Read the file located at {filepath} and split each line by whitespace.
    #
    # Use the fist row as the header row, and create an array of hashes for
    # each line, with the header values as the hash keys.
    #
    # @return [Array<Hash{Symbol => String}>]
    #
    def read_with_header
      rows = read
      return rows if rows == []
      columns = rows.shift.map!(&:downcase.to_sym)
      rows.map! do |row|
        {}.tap do |h|
          columns.each.with_index do |col, i|
            h[col] = row[i]
          end
        end
      end
    end

    ##
    # Read the file located at {filepath} and split each line by whitespace.
    #
    # @return [Array<Array<String>>]
    #
    def read
      open(@filepath)
        .readlines
        .map!(&:strip!)
        .map! { |i| i.split(/\s+/) }
    end
  end
end
