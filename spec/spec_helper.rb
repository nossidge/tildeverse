require 'bundler/setup'
Bundler.setup

# Don't need to test each site's scrape code.
require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter 'tildeverse/sites'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tildeverse'

RSpec.configure do |config|
  # some (optional) config here
end

RSpec::Matchers.define :be_boolean do
  match do |value|
    [true, false].include? value
  end
end
