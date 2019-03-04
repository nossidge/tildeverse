#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

##
# Additional methods for the Pathname class
#
class Pathname
  ##
  # Start a {Pathname#glob} lookup at the pathname located at +self+
  #
  # @param input [String] a glob to use to find files/directories
  #
  # @example
  #   Pathname.new(__dir__).glob('*.txt')
  #   Pathname.new(__dir__).glob('*/*.rb')
  #   Pathname.new(__dir__).glob('**/**')
  #   Pathname.new(__dir__).glob('**/core_extensions/**')
  #
  def glob(input)
    Pathname.glob(to_s + '/' + input.to_s)
  end

  ##
  # Read the first line of the file
  #
  # @note Ported from Facets:
  #   https://www.rubydoc.info/github/rubyworks/facets/Pathname:readline
  #
  # @note See IO#readline for argument documentation:
  #   https://ruby-doc.org/core-2.3.3/IO.html#method-i-readline
  #
  def readline(*args)
    open { |f| f.readline(*args) }
  end
end
