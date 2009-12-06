require File.expand_path(File.dirname(__FILE__) + '/lib/jslint')
require File.expand_path(File.dirname(__FILE__) + '/lib/jslint/rails')

puts "\n"

begin
  JSLint::Utils.remove_config_file
rescue StandardError => error
  puts "Error: #{error.message}"
end

puts "JSLint on Rails plugin has been removed."
