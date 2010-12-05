require "rubygems"
require "bundler"
Bundler.setup

require 'rspec/core/rake_task'

desc 'Run the specs'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--colour', '--format', 'documentation']
end
