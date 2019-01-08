#!/usr/bin/env ruby
# frozen_string_literal: true

module Tildeverse
  ##
  # @return [String] the number of the current version
  # @example
  #   '1.2.0'
  #   '0.0.1.pre'
  #
  def self.version_number
    major = 0
    minor = 0
    tiny  = 3
    pre   = nil

    [major, minor, tiny, pre].compact.join('.')
  end

  ##
  # @return [String] the date of the current version
  # @example
  #   '2017-07-28'
  #
  def self.version_date
    '2018-11-18'
  end
end
