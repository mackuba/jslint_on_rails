require File.dirname(__FILE__) + '/../lib/jslint_on_rails'

namespace :test do

  desc "..."
  task :jslint do
    files = Dir['public/javascripts/hapnin/*.js']
    JSLintOnRails.options = { :undef => false, :eqeqeq => false, :immed => false }
    JSLintOnRails.lint_files(files)
  end

end
