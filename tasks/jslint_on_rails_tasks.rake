require File.dirname(__FILE__) + '/../lib/jslint_on_rails'

desc "Runs JSLint check on selected Javascript files"
task :jslint do
  JSLintOnRails.run_lint
end
