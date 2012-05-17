require 'fileutils'
require 'yaml'

module JSLint
  class << self
    attr_writer :config_path

    def config_path
      @config_path || standard_config_location
    end
  end

  class Config
    DEFAULT_CONFIG_FILE = File.expand_path("../config/jslint.yml", __FILE__)

    attr_reader :files, :options

    # available options:
    # :paths => [list of paths...]
    # :exclude_paths => [list of exluded paths...]
    # :config_path => path to custom config file (can be set via JSLint.config_path too)

    def initialize(params = {})
      default_options = load_config_file(DEFAULT_CONFIG_FILE)
      custom_options = load_config_file(params[:config_path] || JSLint.config_path)

      @options = default_options.merge(custom_options)
      @options['predef'] = @options['predef'].split(",") unless @options['predef'].is_a?(Array)

      included_files = files_matching_paths(params, :paths)
      excluded_files = files_matching_paths(params, :exclude_paths)

      @files = exclude_files(included_files, excluded_files)
      @files.delete_if { |f| File.size(f) == 0 }

      ['paths', 'exclude_paths'].each { |field| @config.delete(field) }
    end


    private

    def in_rails?
      defined?(Rails)
    end

    def standard_config_location
      if in_rails?
        File.expand_path(File.join(Rails.root, 'config', 'jslint.yml'))
      else
        'config/jslint.yml'
      end
    end

    def load_config_file(file_name)
      if file_name && File.exists?(file_name) && File.file?(file_name) && File.readable?(file_name)
        YAML.load_file(file_name)
      else
        {}
      end
    end

    def files_matching_paths(params, field)
      path_list = params[field] || @options[field.to_s] || []
      path_list = [path_list] unless path_list.is_a?(Array)
      file_list = path_list.map { |p| Dir[p] }.flatten
      unique_files(file_list)
    end

    # workaround for a problem with case-insensitive file systems like HFS on Mac
    def exclude_files(list, excluded)
      list.reject { |entry| excluded.any? { |f| File.identical?(f, entry) }}
    end

    # workaround for a problem with case-insensitive file systems like HFS on Mac
    def unique_files(list)
      files = []
      list.each do |entry|
        files << entry unless files.any? { |f| File.identical?(f, entry) }
      end
      files
    end
  end
end
