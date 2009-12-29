lib_dir = File.expand_path(File.dirname(__FILE__) + '/../lib')
$LOAD_PATH << lib_dir unless $LOAD_PATH.include?(lib_dir)

require 'jslint/tasks'
require 'jslint/rails'
