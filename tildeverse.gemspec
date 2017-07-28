# Encoding: UTF-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tildeverse/version.rb'

Gem::Specification.new do |s|
  s.name          = 'tildeverse'
  s.authors       = ['Paul Thompson']
  s.email         = ['nossidge@gmail.com']

  s.summary       = %q{Tildeverse users scraper}
  s.description   = %q{Get a list of all users in the Tildeverse.}
  s.homepage      = 'https://github.com/nossidge/tildeverse'

  s.version       = Tildeverse.version_number
  s.date          = Tildeverse.version_date
  s.license       = 'GPL-3.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency('text-hyphen', '~> 1.4', '>= 1.4.1')

  s.add_development_dependency('bundler', '~> 1.13')
  s.add_development_dependency('rake',    '~> 10.0')
  s.add_development_dependency('rspec',   '~> 3.0')
end
