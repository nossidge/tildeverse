lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tildeverse/version'

Gem::Specification.new do |s|
  s.name          = 'tildeverse'
  s.authors       = ['Paul Thompson']
  s.email         = ['nossidge@gmail.com']

  s.summary       = 'Tildeverse users scraper'
  s.description   = 'A directory of all users in the Tildeverse'
  s.homepage      = 'https://github.com/nossidge/tildeverse'

  s.version       = Tildeverse.version_number
  s.date          = Tildeverse.version_date
  s.license       = 'GPL-3.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency('bundler', '~> 1.13')
  s.add_development_dependency('rake',    '~> 10.0')
  s.add_development_dependency('rspec',   '~> 3.0')
  s.add_development_dependency('sinatra', '~> 2.0', '>= 2.0.2')
  s.add_development_dependency('simplecov', '~> 0.10', '>= 0.10.2')
end
