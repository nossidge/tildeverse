#!/usr/bin/env ruby
# Encoding: UTF-8

################################################################################
# Lots of copy-pasting going on here. Each tilde is in a separate function.
#   I figured it was best to do it this way as no two Tildes are the same,
#   scraping wise. It wouldn't make sense to try to work out commonalities.
################################################################################

require 'json'

require_relative 'core_extensions/string'
require_relative 'tilde_connection'
require_relative 'tilde_site'
require_relative 'misc'

################################################################################

module Tildeverse

################################################################################

# These are the only lines on the page that begin with '<li>'
# 2016/02/23  RIP
def self.read_totallynuclear_club
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('totallynuclear.club')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/^<li>/)
      user = i.first_between_two_chars('"').remove_trailing_slash
      user.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the only lines on the page that begin with '<li>'
def self.read_palvelin_club
  site = TildeSite.new('palvelin.club')
  tc = site.connection
  return [] if tc.error

  # This is very hacky, but it fixes the string encoding problem.
  users = tc.result[89..-1].split("\n").map do |i|
    if i.match(/^<li>/)
      i.first_between_two_chars('"').split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the only lines on the page that begin with '<li>'
# 2015/06/13  RIP
def self.read_tilde_center
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('tilde.center')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/^<li/)
      user = i.split('a href').last.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the lines on the page that begin with '<li>'
# But only after the line '<div class="row" id="members">'
#   and before '</ul>'
#
# 2015/03/05  RIP, I guess?
# http://noiseandsignal.com/~tyler/ still exists though...
# 2015/10/26  RIP
def self.read_noiseandsignal_com
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('noiseandsignal.com')
  tc = site.connection
  return [] if tc.error

  members_found = false
  users = tc.result.split("\n").map do |i|
    members_found = true  if i.match(/<div class="row" id="members">/)
    members_found = false if i.match(/<\/ul>/)
    if members_found and i.match(/<li/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# Current as of 2015/11/13
# Uses a nice JSON format.
def self.read_ctrl_c_club
  site = TildeSite.new('ctrl-c.club')
  tc = site.connection
  return [] if tc.error

  parsed = JSON[ tc.result.gsub("\t",'') ]
  users = parsed['users'].map do |i|
    i['username']
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the only lines on the page that begin with '<li>'
def self.read_tilde_club
  site = TildeSite.new('tilde.club')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/^<li>/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# 2016/08/05  JSON is incomplete, so merge with index.html user list

# A nice easy JSON format.
def self.read_tilde_town_json
  site = TildeSite.new('tilde.town')
  tc = site.connection('http://tilde.town/~dan/users.json')
  return [] if tc.error

  parsed = JSON[ tc.result.gsub("\t",'') ]
  users = parsed.map do |i|
    i.first
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

########################################

# These are the lines on the page that include 'a href'
# But only after the line '<sub>sorted by recent changes</sub>'
#   and before the closing '</ul>'
def self.read_tilde_town_html
  site = TildeSite.new('tilde.town')
  tc = site.connection('http://tilde.town/')
  return [] if tc.error

  members_found = false
  users = tc.result.split("\n").map do |i|
    members_found = true  if i.match(/<sub>sorted by recent changes<\/sub>/)
    members_found = false if i.match(/<\/ul>/)
    if members_found and i.match(/a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

########################################

def self.read_tilde_town
  a = read_tilde_town_json
  b = read_tilde_town_html
  a.concat(b).sort.uniq
end

################################################################################

# These are the lines on the page that include '<li><a href'
# 2018/02/25  RIP
def self.read_tildesare_cool
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('tildesare.cool')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<li><a href=/)
      user = i.split('a href').last.strip
      user = user.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are lines on the page that include '<li><a href', after the line that
#   matches '<p>Current users:</p>'
def self.read_hackers_cool
  site = TildeSite.new('hackers.cool')
  tc = site.connection
  return [] if tc.error

  # There's an error with some URLs, so we need to use the anchor text.
  members_found = false
  users = tc.result.split("\n").map do |i|
    members_found = true if i.strip == '<p>Current users:</p>'
    if members_found and i.match(/<li><a href/)
      i.split('~').last.split('<').first.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
def self.read_tilde_works
  site = TildeSite.new('tilde.works')
  tc = site.connection
  return [] if tc.error

  members_found = false
  users = tc.result.split("\n").map do |i|
    members_found = true  if i.strip == '<h2>users</h2>'
    members_found = false if i.strip == '</ul>'
    if members_found and i.match(/<li><a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2015/10/26  RIP
def self.read_hypertext_website
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('hypertext.website')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<li><a href/)
      user = i.first_between_two_chars("'").strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the only lines on the page that include '<tr><td><a href'
def self.read_squiggle_city_html
  site = TildeSite.new('squiggle.city')
  tc = site.connection('https://squiggle.city/')
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<tr><td><a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

########################################

# JSON format. There's a NULL record at the end of the file though.
# Also, doesn't seem to include all users...
def self.read_squiggle_city_json
  site = TildeSite.new('squiggle.city')
  tc = site.connection('https://squiggle.city/tilde.json')
  return [] if tc.error

  parsed = JSON[ tc.result.gsub("\t",'') ]
  users = parsed['users'].map do |i|
    i['username']
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

########################################

# The JSON doesn't include all the users.
# So group them together, sort and uniq.
def self.read_squiggle_city
  a = read_squiggle_city_html
  b = read_squiggle_city_json
  a.concat(b).sort.uniq
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2016/02/24  RIP
# 2016/08/14  Back!
# 2017/04/11  RIP again
def self.read_tilde_red
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('tilde.red')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<li><a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# Manually found 2 users, but no list.
# 2015/06/13  RIP
def self.read_tilde_city
  return [] unless TRY_KNOWN_DEAD_SITES
  %w{twilde skk}
end

################################################################################

# These are the only lines on the page that include '<li><a href'
def self.read_yester_host_html
  site = TildeSite.new('yester.host')
  tc = site.connection('http://yester.host/')
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<li><a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

########################################

# JSON format. There's a NULL record at the end of the file though.
def self.read_yester_host_json
  site = TildeSite.new('yester.host')
  tc = site.connection('http://yester.host/tilde.json')
  return [] if tc.error

  parsed = JSON[ tc.result.gsub("\t",'') ]
  users = parsed['users'].map do |i|
    i['username']
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

########################################

# 2015/06/13  RIP
def self.read_yester_host
  return [] unless TRY_KNOWN_DEAD_SITES
  read_yester_host_json
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2015/03/05  drawbridge.club merged into tilde.town
def self.read_drawbridge_club
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('drawbridge.club')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<li><a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2015/10/26  RIP
def self.read_tilde_camp
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('tilde.camp')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<li><a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2015/06/13  RIP
def self.read_tilde_farm
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('tilde.farm')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<li><a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2015/06/13  RIP
def self.read_rudimentarylathe_org
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('rudimentarylathe.org')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<li><a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2016/09/03  RIP
def self.read_cybyte_club
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('cybyte.club')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<li><a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# A few lists to choose from here:
# https://protocol.club/~insom/protocol.24h.json
# http://protocol.club/~silentbicycle/homepages.html
# http://protocol.club/~insom/protocol.24h.html

# 201x/xx/xx  Use https://protocol.club/~insom/protocol.24h.json
# 2017/04/11  Use http://protocol.club/~insom/protocol.24h.html
#             Also, the https has expired, do use http.
def self.read_protocol_club
  site = TildeSite.new('protocol.club')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/^<li>/)
      user = i.split('href=')[1].first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2016/08/14  RIP: retronet.net
def self.read_retronet_net
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('retronet.net')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<li><a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# Really easy, just read every line of the html.
# 2015/06/13  RIP
def self.read_sunburnt_country
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('sunburnt.country')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2015/03/05  RIP
def self.read_germantil_de
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('germantil.de')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<li><a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# This is straight from someone's ~user index.html.
# I'm betting this will be the first page to break.
# 2015/10/26  RIP
def self.read_bleepbloop_club
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('bleepbloop.club')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<li>/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are lines on the page that include '<li><a href'
# But only between two other lines.
# 2015/10/26  RIP
def self.read_catbeard_city
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('catbeard.city')
  tc = site.connection
  return [] if tc.error

  members_found = false
  users = tc.result.split("\n").map do |i|
    members_found = true  if i.match(/<p>Current inhabitants:</)
    members_found = false if i.match(/<h2>Pages Changed In Last 24 Hours</)
    if members_found and i.match(/<li><a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the only lines on the page that include '<a href'
def self.read_skylab_org
  site = TildeSite.new('skylab.org')
  tc = site.connection
  return [] if tc.error

  members_found = false
  users = tc.result.split("\n").map do |i|
    members_found = true  if i.match(/Personal homepages on skylab.org/)
    members_found = false if i.match(/Close Userlist/)
    if members_found and i.match(/<li><a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the only lines on the page that include '<a href'
# 2017/11/24  RIP
def self.read_riotgirl_club
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('riotgirl.club')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# A bit different, this one. They don't even use Tildes!
def self.read_remotes_club
  site = TildeSite.new('remotes.club')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<li data-last-update/)
      i.split('href="https://').last.split('.').first
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# This is not newline based, so need to do other stuff.
# 2016/02/04  RIP
def self.read_matilde_club
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('matilde.club')
  tc = site.connection
  return [] if tc.error

  users = []
  tc.result.split("\n").each do |i|
    if i.match(/<ul><li>/)
      i.split('</li><li>').each do |j|
        user = i.first_between_two_chars('"').strip
        user = user.remove_trailing_slash.split('~').last.strip
        users << user
      end
    end
  end
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users.compact.sort
end

################################################################################

# Manually found 8 users, but no easily parsable list.
def self.read_pebble_ink
  %w{clach04 contolini elzilrac imt jovan ke7ofi phildini waste}
end

################################################################################

# 2015/01/03  New box, a nice easy JSON format.
# 2016/01/13  RIP
def self.read_club6_nl
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('club6.nl')
  tc = site.connection
  return [] if tc.error

  parsed = JSON[ tc.result.gsub("\t",'') ]
  users = parsed['users'].map do |i|
    i['username']
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# 2015/01/03  New tildebox
# 2015/01/15  User list on index.html
# 2015/06/13  RIP
def self.read_losangeles_pablo_xyz
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('losangeles.pablo.xyz')
  tc = site.connection
  return [] if tc.error

  users = []
  members_found = false
  tc.result.split("\n").each do |i|
    members_found = true if i.match(/<p><b>Users</)
    if members_found and i.match(/<li>/)
      i.split('<li').each do |j|
        j = j.strip.gsub('</li','')
        if j != ''
          users << j.first_between_two_chars('>')
        end
      end
    end
  end
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# 2015/11/17  New tildebox, user list on index.html
# These are the lines on the page that begin with '<li>'
# But only after the line '<h2>users</h2>'
#   and before '</ul>'
def self.read_perispomeni_club
  site = TildeSite.new('perispomeni.club')
  tc = site.connection
  return [] if tc.error

  members_found = false
  users = tc.result.split("\n").map do |i|
    members_found = true  if i.match(/<h2>users<\/h2>/)
    members_found = false if i.match(/<\/ul>/)
    if members_found and i.match(/<li/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# 2016/08/10  New box
# 2016/11/04  Okay, something weird is going on here. Every page but the index
#             reverts to root. I guess consider it dead?
#             Alright, for now just use cached users. But keep a watch on it.
# 2017/09/04  RIP
def self.read_spookyscary_science
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('spookyscary.science')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/^<a href/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end
def self.read_spookyscary_science_cache
  %w{_vax aerandir arthursucks deuslapis
    drip roob spiff sternalrub wanderingmind}
end

################################################################################

# 2016/09/12  New box
# These are the only lines on the page that begin with '<li><a href='
def self.read_botb_club
  site = TildeSite.new('botb.club')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.strip.match(/^<li><a href=/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# 2017/04/11  New box, user list on index.html
def self.read_crime_team
  site = TildeSite.new('crime.team')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.strip.match(/^<li>/)
      user = i.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# 2017/04/11  New box
# Manually found 8 users, but no list.
def self.read_backtick_town
  %w{alyssa j jay nk kc nickolas360 nix tb10}
end

################################################################################

# Manually found 3 users, but no list.
def self.read_ofmanytrades_com
  %w{ajroach42 djsundog noah}
end

################################################################################

# No idea about this one.
def self.read_oldbsd_club
  []
end

################################################################################

# 2017/08/06  New box
# These are lines on the page that start with '<h5'.
def self.read_tilde_team
  site = TildeSite.new('tilde.team')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.strip.match(/^<h5/)
      i.split('~').last.split('<').first
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# These are the lines on the page that include '<p> <a href'
# 2017/11/24  RIP
def self.read_myrtle_st_club
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('myrtle-st.club')
  tc = site.connection
  return [] if tc.error

  users = tc.result.split("\n").map do |i|
    if i.match(/<p> <a href=/)
      user = i.split('a href').last.first_between_two_chars('"').strip
      user.remove_trailing_slash.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.length == 0
  users
end

################################################################################

# 2018/02/27  New box
# There's a strange issue with curling this URL.
# I'll just use a manual list for now.
def self.read_yourtilde_com
  %w{WL01 deepend emv jovan kingofobsolete login mhj msmcmickey mushmouth
      nozy sebboh ubergeek}
end

################################################################################

end

################################################################################
