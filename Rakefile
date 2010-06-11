require "rubygems"
require "bundler"
Bundler.setup

require 'spec/rake/spectask'

desc 'Run the specs'
Spec::Rake::SpecTask.new do |t|
  t.libs << 'lib'
  t.spec_opts = ['--colour', '--format', 'specdoc']
end
