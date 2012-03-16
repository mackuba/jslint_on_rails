module JSLint
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'jslint/tasks'
    end
  end
end
