#!/usr/bin/env ruby

################################################################################
# Lots of copy-pasting going on here. Each tilde is in a separate function.
#   I figured it was best to do it this way as no two Tildes are the same,
#   scraping wise. It wouldn't make sense to try to work out commonalities.
################################################################################

module Tildeverse

################################################################################

# These are the only lines on the page that begin with '<li>'
# 2016/02/23  RIP
def self.read_totallynuclear_club
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('totallynuclear.club')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    if i =~ /^<li>/
      user = i.first_between_two_chars('"').remove_trailing_slash
      user.split('~').last.strip
    end
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

def self.read_palvelin_club
  PalvelinClub.new.users
end

################################################################################

# These are the only lines on the page that begin with '<li>'
# 2015/06/13  RIP
def self.read_tilde_center
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('tilde.center')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /^<li/
    user = i.split('a href').last.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
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
  con = site.connection
  return [] if con.error

  members_found = false
  users = con.result.split("\n").map do |i|
    members_found = true  if i =~ /<div class="row" id="members">/
    members_found = false if i =~ %r{</ul>}
    next unless members_found && i =~ /<li/
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

def self.read_ctrl_c_club
  CtrlCClub.new.users
end

################################################################################

# These are the only lines on the page that begin with '<li>'
def self.read_tilde_club
  TildeClub.new.users
end

################################################################################

# 2016/08/05  JSON is incomplete, so merge with index.html user list
def self.read_tilde_town
  TildeTown.new.users
end

################################################################################

# These are the lines on the page that include '<li><a href'
# 2018/02/25  RIP
def self.read_tildesare_cool
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('tildesare.cool')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /<li><a href=/
    user = i.split('a href').last.strip
    user = user.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# These are lines on the page that include '<li><a href', after the line that
#   matches '<p>Current users:</p>'
def self.read_hackers_cool
  HackersCool.new.users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
def self.read_tilde_works
  TildeWorks.new.users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2015/10/26  RIP
def self.read_hypertext_website
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('hypertext.website')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /<li><a href/
    user = i.first_between_two_chars("'").strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# The JSON doesn't include all the users.
# So group them together, sort and uniq.
def self.read_squiggle_city
  SquiggleCity.new.users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2016/02/24  RIP
# 2016/08/14  Back!
# 2017/04/11  RIP again
def self.read_tilde_red
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('tilde.red')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /<li><a href/
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# Manually found 2 users, but no list.
# 2015/06/13  RIP
def self.read_tilde_city
  return [] unless TRY_KNOWN_DEAD_SITES
  %w[twilde skk]
end

################################################################################

# These are the only lines on the page that include '<li><a href'
def self.read_yester_host_html
  site = TildeSite.new('yester.host')
  con = site.connection('http://yester.host/')
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /<li><a href/
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

########################################

# JSON format. There's a NULL record at the end of the file though.
def self.read_yester_host_json
  site = TildeSite.new('yester.host')
  con = site.connection('http://yester.host/tilde.json')
  return [] if con.error

  parsed = JSON[con.result.delete("\t")]
  users = parsed['users'].map do |i|
    i['username']
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
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
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /<li><a href/
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2015/10/26  RIP
def self.read_tilde_camp
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('tilde.camp')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /<li><a href/
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2015/06/13  RIP
def self.read_tilde_farm
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('tilde.farm')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /<li><a href/
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2015/06/13  RIP
def self.read_rudimentarylathe_org
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('rudimentarylathe.org')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /<li><a href/
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2016/09/03  RIP
def self.read_cybyte_club
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('cybyte.club')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /<li><a href/
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

def self.read_protocol_club
  ProtocolClub.new.users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2016/08/14  RIP: retronet.net
def self.read_retronet_net
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('retronet.net')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /<li><a href/
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# Really easy, just read every line of the html.
# 2015/06/13  RIP
def self.read_sunburnt_country
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('sunburnt.country')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# These are the only lines on the page that include '<li><a href'
# 2015/03/05  RIP
def self.read_germantil_de
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('germantil.de')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /<li><a href/
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# This is straight from someone's ~user index.html.
# I'm betting this will be the first page to break.
# 2015/10/26  RIP
def self.read_bleepbloop_club
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('bleepbloop.club')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /<li>/
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# These are lines on the page that include '<li><a href'
# But only between two other lines.
# 2015/10/26  RIP
def self.read_catbeard_city
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('catbeard.city')
  con = site.connection
  return [] if con.error

  members_found = false
  users = con.result.split("\n").map do |i|
    members_found = true  if i =~ /<p>Current inhabitants:</
    members_found = false if i =~ /<h2>Pages Changed In Last 24 Hours</
    next unless members_found && i =~ /<li><a href/
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# These are the only lines on the page that include '<a href'
def self.read_skylab_org
  SkylabOrg.new.users
end

################################################################################

# These are the only lines on the page that include '<a href'
# 2017/11/24  RIP
def self.read_riotgirl_club
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('riotgirl.club')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /<a href/
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# A bit different, this one. They don't even use Tildes!
def self.read_remotes_club
  RemotesClub.new.users
end

################################################################################

# This is not newline based, so need to do other stuff.
# 2016/02/04  RIP
def self.read_matilde_club
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('matilde.club')
  con = site.connection
  return [] if con.error

  users = []
  con.result.split("\n").each do |i|
    next unless i =~ /<ul><li>/
    i.split('</li><li>').each do
      user = i.first_between_two_chars('"').strip
      user = user.remove_trailing_slash.split('~').last.strip
      users << user
    end
  end
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users.compact.sort
end

################################################################################

# Manually found 8 users, but no easily parsable list.
def self.read_pebble_ink
  PebbleInk.new.users
end

################################################################################

# 2015/01/03  New box, a nice easy JSON format.
# 2016/01/13  RIP
def self.read_club6_nl
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('club6.nl')
  con = site.connection
  return [] if con.error

  parsed = JSON[con.result.delete("\t")]
  users = parsed['users'].map do |i|
    i['username']
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# 2015/01/03  New tildebox
# 2015/01/15  User list on index.html
# 2015/06/13  RIP
def self.read_losangeles_pablo_xyz
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('losangeles.pablo.xyz')
  con = site.connection
  return [] if con.error

  users = []
  members_found = false
  con.result.split("\n").each do |i|
    members_found = true if i =~ /<p><b>Users</
    next unless members_found && i =~ /<li>/
    i.split('<li').each do |j|
      j = j.strip.delete('</li')
      users << j.first_between_two_chars('>') unless j == ''
    end
  end
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# 2015/11/17  New tildebox, user list on index.html
# These are the lines on the page that begin with '<li>'
# But only after the line '<h2>users</h2>'
#   and before '</ul>'
def self.read_perispomeni_club
  PerispomeniClub.new.users
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
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /^<a href/
    user = i.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

def self.read_spookyscary_science_cache
  %w[_vax aerandir arthursucks deuslapis
     drip roob spiff sternalrub wanderingmind]
end

################################################################################

# 2016/09/12  New box
# These are the only lines on the page that begin with '<li><a href='
def self.read_botb_club
  BotbClub.new.users
end

################################################################################

# 2017/04/11  New box, user list on index.html
def self.read_crime_team
  CrimeTeam.new.users
end

################################################################################

# 2017/04/11  New box
# Manually found 8 users, but no list.
def self.read_backtick_town
  BacktickTown.new.users
end

################################################################################

# Manually found 3 users, but no list.
def self.read_ofmanytrades_com
  OfmanytradesCom.new.users
end

################################################################################

# No idea about this one.
def self.read_oldbsd_club
  OldbsdClub.new.users
end

################################################################################

# 2017/08/06  New box
# These are lines on the page that start with '<h5'.
def self.read_tilde_team
  TildeTeam.new.users
end

################################################################################

# These are the lines on the page that include '<p> <a href'
# 2017/11/24  RIP
def self.read_myrtle_st_club
  return [] unless TRY_KNOWN_DEAD_SITES

  site = TildeSite.new('myrtle-st.club')
  con = site.connection
  return [] if con.error

  users = con.result.split("\n").map do |i|
    next unless i =~ /<p> <a href=/
    user = i.split('a href').last.first_between_two_chars('"').strip
    user.remove_trailing_slash.split('~').last.strip
  end.compact.sort.uniq
  puts "ERROR: Empty hash in method: #{__method__}" if users.empty?
  users
end

################################################################################

# 2018/02/27  New box
# There's a strange issue with curling this URL.
# I'll just use a manual list for now.
def self.read_yourtilde_com
  YourtildeCom.new.users
end

################################################################################

end

################################################################################
