require File.dirname(__FILE__) + '/lib/jslint_on_rails'

puts "\n"

begin
  JSLintOnRails.copy_config_file
rescue StandardError => error
  puts "Error: #{error.message}"
end

puts "\n"
puts "JSLint on Rails plugin is now installed. Take a look at the config file (config/jslint.yml) " +
     "and use 'rake jslint' to start the test.\nHappy debugging! :)"
