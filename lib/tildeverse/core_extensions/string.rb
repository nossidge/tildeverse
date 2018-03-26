#!/usr/bin/env ruby

# Additional methods for the String class.
class String
  ##
  # Remove trailing slash if there is one.
  #
  # @return [String]
  #   Self with trailing slash removed.
  #
  def remove_trailing_slash
    self[-1] == '/' ? self[0...-1] : self
  end

  ##
  # Get the string between the first and second occurrences of a char.
  #
  # @param [String] char
  #   Character to scan between.
  # @return [nil]
  #   If char invalid or char.length > 1.
  # @return [String]
  #   String between the first and second occurrences.
  #
  def first_between_two_chars(char = '"')
    between = scan(/#{char}([^#{char}]*)#{char}/).first
    between.join if between
  end
end
