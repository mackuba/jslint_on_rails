require File.dirname(__FILE__) + '/lib/jslint_on_rails'

begin
  JSLintOnRails.copy_config_file
rescue StandardError => error
  puts "Error: #{error.message}"
end
