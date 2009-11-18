require File.dirname(__FILE__) + '/../lib/jslint_on_rails'

namespace :test do

  desc "..."
  task :jslint do
    # TODO pass parameters
    JSLintOnRails.lint_files
  end

end
