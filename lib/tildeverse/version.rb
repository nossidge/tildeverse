#!/usr/bin/env ruby
# Encoding: UTF-8

module Tildeverse

  ##
  # The number of the current version.
  #
  def self.version_number
    major = 0
    minor = 0
    tiny  = 1
    pre   = 'pre'

    string = [major, minor, tiny, pre].compact.join('.')
  end

  ##
  # The date of the current version.
  #
  def self.version_date
    '2017-07-28'
  end
end
