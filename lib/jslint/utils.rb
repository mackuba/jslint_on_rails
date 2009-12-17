require 'ftools'

module JSLint

  DEFAULT_CONFIG_FILE = File.expand_path(File.dirname(__FILE__) + "/../../config/jslint.yml")

  class << self
    attr_accessor :config_path
  end

  module Utils
    class << self

      def load_config_file(file_name)
        if file_name && File.exists?(file_name) && File.file?(file_name) && File.readable?(file_name)
          YAML.load_file(file_name)
        else
          {}
        end
      end

      # workaround for a problem with case-insensitive file systems like HFS on Mac
      def unique_files(list)
        files = []
        list.each do |entry|
          files << entry unless files.any? { |f| File.identical?(f, entry) }
        end
        files
      end

      # workaround for a problem with case-insensitive file systems like HFS on Mac
      def exclude_files(list, excluded)
        list.reject { |entry| excluded.any? { |f| File.identical?(f, entry) }}
      end

      def paths_from_command_line(field)
        argument = ENV[field] || ENV[field.upcase]
        argument && argument.split(/,/)
      end

      def copy_config_file
        raise ArgumentError, "Please set JSLint.config_path" if JSLint.config_path.nil?
        print "Copying default config file to #{File.expand_path(JSLint.config_path)}... "
        if File.exists?(JSLint.config_path)
          puts "\n\nWarning: config file exists, so it won't be overwritten. " +
               "You can copy it manually from the jslint_on_rails directory if you want to reset it."
        else
          File.copy(JSLint::DEFAULT_CONFIG_FILE, JSLint.config_path)
          puts "OK."
        end
      end

      def remove_config_file
        raise ArgumentError, "Please set JSLint.config_path" if JSLint.config_path.nil?
        print "Removing config file... "
        if File.exists?(JSLint.config_path) && File.file?(JSLint.config_path)
          if File.read(JSLint.config_path) == File.read(JSLint::DEFAULT_CONFIG_FILE)
            File.delete(JSLint.config_path)
            puts "OK."
          else
            puts "File was modified, so it won't be deleted automatically."
          end
        else
          puts "OK (no config file found)."
        end
      end

    end
  end
end
