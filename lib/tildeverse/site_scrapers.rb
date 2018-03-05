#!/usr/bin/env ruby

# Require all files in the subdirectory with the same name as this file.
Dir["#{__FILE__.rpartition('.rb').first}/*.rb"].each { |file| require file }
