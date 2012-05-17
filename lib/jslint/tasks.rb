require 'jslint/lint'
require 'jslint/utils'

desc "Run JSLint check on selected Javascript files"
task :jslint do
  include_paths = JSLint::Utils.paths_from_command_line('paths')
  exclude_paths = JSLint::Utils.paths_from_command_line('exclude_paths')

  if include_paths && exclude_paths.nil?
    # if you pass paths= on command line but not exclude_paths=, and you have exclude_paths
    # set in the config file, then the old exclude pattern will be used against the new
    # include pattern, which may be very confusing...
    exclude_paths = []
  end

  lint = JSLint::Lint.new :paths => include_paths, :exclude_paths => exclude_paths
  lint.run
end

namespace :jslint do

  desc "Create a copy of the default JSLint config file in your config directory"
  task :copy_config do
    print "Creating example JSLint config file in #{File.expand_path(JSLint.config_path)}... "

    if File.exists?(JSLint.config_path)
      puts "\n\nWarning: config file exists, so it won't be overwritten. " +
          "You can copy it manually from the jslint_on_rails directory if you want to reset it."
    else
      FileUtils.copy(JSLint::DEFAULT_CONFIG_FILE, JSLint.config_path)
      puts "done."
    end
  end

end
