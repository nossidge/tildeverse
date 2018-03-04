#!/usr/bin/env ruby

################################################################################

# Load all the files in the site_scrapers directory.
Dir["#{__FILE__[0...-3]}/*.rb"].each { |file| require file }

################################################################################

__END__

site = Tildeverse::PalvelinClub.new
puts site.name
puts site.users
