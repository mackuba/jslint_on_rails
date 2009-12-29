require 'jslint/utils'
require 'jslint/rails'

puts "\n"

begin
  JSLint::Utils.remove_config_file
rescue StandardError => error
  puts "Error: #{error.message}"
end

puts "JSLint on Rails plugin has been removed."
