require 'bundler/setup'
Bundler.setup

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
