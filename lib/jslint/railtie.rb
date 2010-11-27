module JSLint
  class Railtie < Rails::Railtie

    rake_tasks do
      require 'jslint/rails'
      require 'jslint/tasks'
      JSLint::Railtie.create_example_config
    end

    def self.create_example_config
      unless File.exists?(JSLint.config_path)
        begin
          JSLint::Utils.copy_config_file
        rescue StandardError => error
          puts "Error: #{error.message}"
        end
      end
    end

  end
end
