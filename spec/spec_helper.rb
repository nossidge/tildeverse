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
  config.before(:each) do
    allow(Tildeverse::Files).to receive(:dir_root) do
      Pathname(__FILE__).dirname.parent + 'spec'
    end

    # Ensure the directories exist
    makedirs = ->(dir) { FileUtils.makedirs(dir) unless dir.exist? }
    makedirs.call(Tildeverse::Files.dir_root)
    makedirs.call(Tildeverse::Files.dir_input)
    makedirs.call(Tildeverse::Files.dir_output)

    # Copy over the seed file
    from = Tildeverse::Files.dir_root + 'seed' + 'tildeverse.txt'
    to   = Tildeverse::Files.dir_input + 'tildeverse.txt'
    FileUtils.cp(from, to)

    # Touch the static files
    # They can be empty, that's okay for testing
    %w[index.html users.js boxes.js pie.js].each do |f|
      FileUtils.touch(Tildeverse::Files.dir_input + f)
    end

    # Save to JSON file
    Tildeverse.data.save
  end
end

RSpec::Matchers.define :be_boolean do
  match do |value|
    [true, false].include? value
  end
end
