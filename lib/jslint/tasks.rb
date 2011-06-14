require 'jslint/lint'
require 'jslint/utils'

desc "Run lint on selected Javascript files"
task :jslint do
  include_paths, exclude_paths = lint_options
  engine = ENV['lint_engine'] || ENV['LINT_ENGINE']
  lint = JSLint::Lint.new :lint_engine => engine, :paths => include_paths, :exclude_paths => exclude_paths
  lint.run
end

namespace :jslint do

  desc "Create a copy of the default JSLint config file in your config directory"
  task :copy_config do
    JSLint::Utils.copy_config_file
  end

end

def lint_options
  include_paths = JSLint::Utils.paths_from_command_line('paths')
  exclude_paths = JSLint::Utils.paths_from_command_line('exclude_paths')

  if include_paths && exclude_paths.nil?
    # if you pass paths= on command line but not exclude_paths=, and you have exclude_paths
    # set in the config file, then the old exclude pattern will be used against the new
    # include pattern, which may be very confusing...
    exclude_paths = []
  end

  [include_paths, exclude_paths]
end
