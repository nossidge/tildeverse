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

################################################################################

# Remap the root directory to /spec/
module Tildeverse::Files
  class << self
    alias_method :old_dir_root, :dir_root
    def dir_root
      old_dir_root + 'spec'
    end
  end
end


# Revert to the seed data, and rewrite the JSON file
module RspecCustomHelpers
  def self.seed_the_data
    from = Tildeverse::Files.dir_root + 'seed' + 'tildeverse.txt'
    to   = Tildeverse::Files.dir_input + 'tildeverse.txt'
    FileUtils.cp(from, to)
    Tildeverse.data.save
  end
end


# Declare a shared context that will re-seed the data before each test
# (This might get expensive, so we should only do it for certain tests)
RSpec.shared_context 'before_each__seed_the_data' do
  before(:each) do
    RspecCustomHelpers.seed_the_data
  end
end


RSpec.configure do |config|
  config.before(:all) do

    # Ensure the directories exist
    makedirs = ->(dir) { FileUtils.makedirs(dir) unless dir.exist? }
    makedirs.call(Tildeverse::Files.dir_root)
    makedirs.call(Tildeverse::Files.dir_input)
    makedirs.call(Tildeverse::Files.dir_output)

    # Copy the seed data, and rewrite the JSON file
    RspecCustomHelpers.seed_the_data

    # Touch the static files
    # (They can be empty, that's okay for testing)
    %w[index.html users.js boxes.js pie.js].each do |f|
      FileUtils.touch(Tildeverse::Files.dir_input + f)
    end
  end
end


RSpec::Matchers.define :be_boolean do
  match do |value|
    [true, false].include? value
  end
end
