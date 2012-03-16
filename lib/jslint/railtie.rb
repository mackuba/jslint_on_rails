module JSLint
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'jslint/rails'
      require 'jslint/tasks'
    end
  end
end
