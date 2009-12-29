lib_dir = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH << lib_dir unless $LOAD_PATH.include?(lib_dir)

require 'jslint/utils'
require 'jslint/rails'

puts "\n"

begin
  JSLint::Utils.copy_config_file
rescue StandardError => error
  puts "Error: #{error.message}"
end

puts "\n"
puts "JSLint on Rails plugin is now installed. Take a look at the config file (config/jslint.yml) " +
     "and use 'rake jslint' to start the test.\nHappy JavaScript testing! :)"
