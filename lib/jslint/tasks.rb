require File.expand_path(File.dirname(__FILE__) + '/../jslint')

desc "Run JSLint check on selected Javascript files"
task :jslint do
  lint = JSLint::Lint.new(
    :paths => JSLint::Utils.paths_from_command_line('paths'),
    :exclude_paths => JSLint::Utils.paths_from_command_line('exclude_paths')
  )
  lint.run
end

namespace :jslint do

  desc "Create a copy of the default JSLint config file in your config directory"
  task :copy_config do
    JSLint::Utils.copy_config_file
  end

end
