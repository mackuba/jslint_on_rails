require File.dirname(__FILE__) + '/lib/jslint_on_rails'

puts "\n"

begin
  JSLintOnRails.remove_config_file
rescue StandardError => error
  puts "Error: #{error.message}"
end

puts "JSLint on Rails plugin has been removed."
