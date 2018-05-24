#!/usr/bin/env ruby

module Tildeverse
  ##
  # Class for parsing from and writing to data in rows of
  # whitespace-separated values.
  #
  class WSV
    ##
    # @return [Array<String>, Array<Array<String>>]
    #   Input lines to be parsed from or to.
    #
    attr_reader :data

    ##
    # @param [Array<String>, Array<Array<String>>] data
    #   Input lines to be parsed from or to.
    #
    def initialize(data)
      @data = data
    end

    ##
    # Read the string array from {data} and split each line by whitespace.
    #
    # Unlike {from_wsv_with_header} and {to_wsv}, the first row is NOT used
    # to judge the number of fields. Any extra fields will be left intact.
    #
    # @return [Array<Array<String>>]
    #
    # @example
    #   folks = [
    #     'NAME   AGE  GENDER',
    #     'Paul    31  m     ',
    #     'Alice   22  nb     extra',
    #     'Sarah    8  f      fields',
    #     'Rahim       m      '
    #   ]
    #   wsv = WSV.new(folks)
    #   wsv.from_wsv
    #
    #   # => [
    #   #   ["NAME", "AGE", "GENDER"],
    #   #   ["Paul", "31", "m"],
    #   #   ["Alice", "22", "nb", "extra"],
    #   #   ["Sarah", "8", "f", "fields"],
    #   #   ["Rahim", "m"]
    #   # ]
    #
    def from_wsv
      @data
        .map!(&:strip)
        .map! { |i| i.split(/\s+/) }
    end

    ##
    # Read the string array from {data} and split each line by whitespace.
    #
    # Use the first row as the header row, and create an array of hashes
    # for each line with the header values as the hash keys.
    # Hash keys are lower-cased and converted to Symbol.
    #
    # The first row is used to judge the number of fields.
    # Any extra fields in later rows will be ignored.
    #
    # @return [Array<Hash{Symbol => String}>]
    #
    # @example
    #   folks = [
    #     'NAME   AGE  GENDER',
    #     'Paul    31  m     ',
    #     'Alice   22  nb     extra',
    #     'Sarah    8  f      fields',
    #     'Rahim       m      '
    #   ]
    #   wsv = WSV.new(folks)
    #   wsv.from_wsv_with_header
    #
    #   # => [
    #   #   {:name=>"Paul", :age=>"31", :gender=>"m"},
    #   #   {:name=>"Alice", :age=>"22", :gender=>"nb"},
    #   #   {:name=>"Sarah", :age=>"8", :gender=>"f"},
    #   #   {:name=>"Rahim", :age=>"m", :gender=>nil}
    #   # ]
    #
    def from_wsv_with_header
      rows = from_wsv
      return rows if rows == []
      columns = rows.shift.map! { |i| i.downcase.to_sym }
      rows.map! do |row|
        {}.tap do |h|
          columns.each.with_index do |col, i|
            h[col] = row[i]
          end
        end
      end
    end

    ##
    # Read the 2D string array from {data} and format
    # as a vertically aligned 1D array of strings.
    #
    # The first row is used to judge the number of fields.
    # Any extra fields in later rows will be ignored.
    #
    # Based on this code: https://stackoverflow.com/a/11747678/139299
    #
    # @param [Array<Integer>] rjust
    #   Array contains the index of fields that should be right-justified.
    #   Left-justified is the default.
    # @return [Array<String>]
    #
    # @example
    #   folks = [
    #     ['NAME', 'AGE', 'GENDER'],
    #     ['Paul', '31', 'm'],
    #     ['Alice', '22', 'nb', 'extra'],
    #     ['Sarah', '8', 'f', 'fields'],
    #     ['Rahim', 'm'],
    #     ['Rahim', nil, 'm']
    #   ]
    #   wsv = WSV.new(folks)
    #   wsv.to_wsv(rjust: [1])
    #
    #   # => [
    #   #   "NAME   AGE  GENDER",
    #   #   "Paul    31  m     ",
    #   #   "Alice   22  nb    ",
    #   #   "Sarah    8  f     ",
    #   #   "Rahim    m        ",
    #   #   "Rahim       m     "
    #   # ]
    #
    def to_wsv(rjust: [], spaces: 2)
      #
      # Figure out max lengths, to use as the width of each column.
      max_lengths = @data.first.map(&:length)
      @data.each do |row|
        row.each_with_index do |e, i|
          next if max_lengths.size == i
          s = e.to_s.size
          max_lengths[i] = s if s > max_lengths[i]
        end
      end

      # Format each row as one long string.
      @data.map do |row|
        format = max_lengths.map.with_index do |value, index|
          just = rjust.include?(index) ? '' : '-'

          # Set a % format string for the field.
          # If the field does not contain a value, fill with spaces.
          index < row.count ? "%#{just}#{value}s" : ' ' * value
        end
        (format.join(' ' * spaces) % row).rstrip
      end
    end
  end
end
