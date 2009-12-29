lib_dir = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH << lib_dir unless $LOAD_PATH.include?(lib_dir)

require 'jslint/utils'
require 'jslint/rails'

puts "\n"

begin
  JSLint::Utils.remove_config_file
rescue StandardError => error
  puts "Error: #{error.message}"
end

puts "JSLint on Rails plugin has been removed."
