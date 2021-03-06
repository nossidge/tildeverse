#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Additional methods for the String class
#
class String
  ##
  # Remove trailing slash if there is one
  #
  # @return [String]
  #   Self with trailing slash removed
  #
  def remove_trailing_slash
    self[-1] == '/' ? self[0...-1] : self
  end

  ##
  # Return the string between the first and second occurrences of a character
  #
  # @param [String] char
  #   Character to scan between
  # @return [nil]
  #   If there are fewer than 2 occurrences of the character
  # @return [String]
  #   String between the first and second occurrences
  #
  def first_between_two_chars(char = '"')
    scan(char).count < 2 ? nil : split(char)[1]
  end

  ##
  # Returns the string, first removing all whitespace on both ends of the
  # string, and then changing remaining consecutive whitespace groups into
  # one space each
  #
  # @note Ported from Rails: https://apidock.com/rails/String/squish
  #
  def squish
    dup.squish!
  end

  ##
  # Performs a destructive {String#squish}
  #
  # @note Ported from Rails: https://apidock.com/rails/String/squish!
  #
  def squish!
    gsub!(/\A[[:space:]]+/, '')
    gsub!(/[[:space:]]+\z/, '')
    gsub!(/[[:space:]]+/, ' ')
    self
  end
end
