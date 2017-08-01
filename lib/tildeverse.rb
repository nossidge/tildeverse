#!/usr/bin/env ruby
# Encoding: UTF-8

################################################################################
# Tildeverse Users Scraper
################################################################################
# Get a list of all users in the Tildeverse.
# Mostly done using HTML scraping, but there are few JSON feeds.
################################################################################

require 'net/http'
require 'net/https'
require 'open-uri'
require 'json'
require 'text/hyphen'
require 'fileutils'

require_relative 'tildeverse/core_extensions/string.rb'
require_relative 'tildeverse/tilde_connection.rb'
require_relative 'tildeverse/read_sites.rb'
require_relative 'tildeverse/misc.rb'

################################################################################

DIR_ROOT                = File.expand_path('../../', __FILE__)
DIR_DATA                = "#{DIR_ROOT}/data/"
DIR_HTML                = "#{DIR_ROOT}/output/"

TEMPLATE_FILE_HTML      = "#{DIR_DATA}/index_template.html"
INPUT_FILE_JSON         = "#{DIR_DATA}/tildeverse.json"
OUTPUT_FILE_HTML        = "#{DIR_HTML}/index.html"
OUTPUT_FILE_JSON        = "#{DIR_HTML}/tildeverse.json"
FILES_TO_COPY           = ['users.js', 'boxes.js', 'pie.js']

WRITE_TO_FILES          = true   # This is necessary.
CHECK_FOR_NEW_BOXES     = false  # This is fast.
CHECK_FOR_NEW_DESC_JSON = false  # This is slow.
TRY_KNOWN_DEAD_SITES    = false  # This is pointless.

################################################################################

module Tildeverse

################################################################################

def self.output_to_files

  # Read in the tildebox names from the JSON.
  boxes = JSON.parse(File.read(INPUT_FILE_JSON))

  # Add current date and time to the hash
  boxes['metadata']['date_human'] = Time.now.strftime('%Y-%m-%d %H:%M:%S')
  boxes['metadata']['date_unix']  = Time.now.to_i

  # Scrape each site and add to the hash.
  boxes['sites'].each do |i|
    key = i.first
    hash = i[1]

    # This is the name of the method that will scrape the site.
    # Each site is different, so they need bespoke methods.
    method_name = 'read_' + key.gsub(/[[:punct:]]/, '_')
    results = Tildeverse.send(method_name)

    hash['online']     = !results.empty?
    hash['user_count'] = results.size
    hash['users']      = results.keys
  end

  # Write the hash to JSON.
  File.open(OUTPUT_FILE_JSON,'w') do |f|
    f.write JSON.pretty_generate(boxes)
  end
end

# Now read back to 'index.html'
def self.write_to_html
  File.open(OUTPUT_FILE_HTML, 'w') do |fo|
    File.open(TEMPLATE_FILE_HTML, 'r') do |fi|
      time_stamp = Time.now.strftime("%Y/%m/%d %H:%M GMT")
      out = fi.read.gsub('<!-- @TIME_STAMP -->', time_stamp)
      fo.puts out
    end
  end
end

# Copy all static files to the ouput directory.
def self.copy_files
  FILES_TO_COPY.each do |i|
    FileUtils.cp("#{DIR_DATA}/#{i}", "#{DIR_HTML}/#{i}")
  end
end

################################################################################

# ~pfhawkins JSON list of all other tildes.
# If this has been updated let me know. Then I can manually add the new box.
def self.get_all_tildes
  string_json = open('http://tilde.club/~pfhawkins/othertildes.json').read
  JSON.parse(string_json).values.map do |i|
    i = i[0...-1] if i[-1] == '/'
    i = i.partition('//').last
  end
end
def self.check_for_new_boxes
  if get_all_tildes.length != 33
    puts '-- New Tilde Boxes!'
    puts 'http://tilde.club/~pfhawkins/othertildes.html'
  end
end

################################################################################

# Check each Tildebox to see if they have a '/tilde.json' file.
# I already know that 3 do, so let me know if that number changes.
#   https://club6.nl/tilde.json
#   http://ctrl-c.club/tilde.json
#   https://squiggle.city/tilde.json
def self.get_all_tilde_json

  # Read from the master list of Tilde URLs, and append '/tilde.json' to them.
  obj_json = JSON.parse( open(OUTPUT_FILE_JSON).read )
  urls_json = obj_json.keys.map { |i| i += '/tilde.json' }

  # Only select the URLs that can be parsed as JSON.
  urls_json.select do |item|
    begin
      JSON.parse( open(item).read )
      true
    rescue
      false
    end
  end
end

def self.check_for_new_desc_json
  tilde_desc_files = get_all_tilde_json
  if tilde_desc_files.length != 3
    puts '-- Tilde Description JSON files:'
    puts tilde_desc_files
    puts nil
  end
end

################################################################################

def self.run_all
  output_to_files if WRITE_TO_FILES
  write_to_html if WRITE_TO_FILES
  copy_files if WRITE_TO_FILES
  check_for_new_boxes if CHECK_FOR_NEW_BOXES
  check_for_new_desc_json if CHECK_FOR_NEW_DESC_JSON
end

################################################################################

end

################################################################################
