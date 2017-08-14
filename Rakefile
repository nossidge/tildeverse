require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end
task :test => :spec

desc "Open server for user site tagging"
task :server do
  require_relative 'lib/tagging_server.rb'
  start_server
end
