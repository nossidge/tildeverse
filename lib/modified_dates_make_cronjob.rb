#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'tildeverse'
require_relative 'tildeverse/modified_dates_make'

include Tildeverse

ModifiedDatesMake.new.make
