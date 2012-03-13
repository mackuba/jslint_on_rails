require 'jslint/utils'

# for Rails, set config file path to config/jslint.yml in Rails root
if !JSLint.config_path.nil?
  fail "JSLint config path #{JSLint.config_path} doesn't exist" if !File.exists?(JSLint.config_path)
else
  JSLint.config_path = File.join(Rails.root, 'config', 'jslint.yml')
end
