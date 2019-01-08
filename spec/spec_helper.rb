# frozen_string_literal: true

require 'bundler/setup'
Bundler.setup

# Don't need to test each site's scrape code
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


# Copy the /seed/ data to /input/, and run {Data#save}
module RspecCustomHelpers
  def self.seed_the_data
    dir_seed = Tildeverse::Files.dir_root + 'seed'
    dir_seed.children.each do |from|
      to = Tildeverse::Files.dir_data + from.basename
      FileUtils.cp(from, to)
    end
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
  config.before(:suite) do

    # Ensure the directories exist
    makedirs = ->(dir) { FileUtils.makedirs(dir) unless dir.exist? }
    makedirs.call(Tildeverse::Files.dir_root)
    makedirs.call(Tildeverse::Files.dir_data)
    makedirs.call(Tildeverse::Files.dir_public)

    # Copy the seed data, and rewrite the JSON file
    RspecCustomHelpers.seed_the_data

    # Touch the static files
    # (They can be empty, that's okay for testing)
    %w[index.html users.js boxes.js pie.js].each do |f|
      FileUtils.touch(Tildeverse::Files.dir_data + f)
    end
  end

  # Kill temporary directories
  config.after(:suite) do
    FileUtils.rm_rf(Tildeverse::Files.dir_root + 'config')
    FileUtils.rm_rf(Tildeverse::Files.dir_data)
    FileUtils.rm_rf(Tildeverse::Files.dir_web)
  end
end


RSpec::Matchers.define :be_boolean do
  match do |value|
    [true, false].include? value
  end
end


# Method to capture and test STDOUT
# https://stackoverflow.com/a/1496040/139299
def capture_stdout
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string.chomp
end
