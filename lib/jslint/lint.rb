module JSLint

  PATH = File.dirname(__FILE__)

  TEST_JAR_FILE = File.expand_path("#{PATH}/../../vendor/test.jar")
  RHINO_JAR_FILE = File.expand_path("#{PATH}/../../vendor/rhino.jar")
  TEST_JAR_CLASS = "Test"
  RHINO_JAR_CLASS = "org.mozilla.javascript.tools.shell.Main"

  JSLINT_FILE = File.expand_path("#{PATH}/../../vendor/jslint.js")

  class Lint

    # available options:
    # :paths => [list of paths...]
    # :exclude_paths => [list of exluded paths...]
    # :config_path => path to custom config file (can be set via JSLint.config_path too)
    def initialize(options = {})
      default_config = Utils.load_config_file(DEFAULT_CONFIG_FILE)
      custom_config = Utils.load_config_file(options[:config_path] || JSLint.config_path)
      @config = default_config.merge(custom_config)

      included_files = files_matching_paths(options, :paths)
      excluded_files = files_matching_paths(options, :exclude_paths)
      @file_list = Utils.exclude_files(included_files, excluded_files)

      ['paths', 'exclude_paths', 'config_path'].each { |field| @config.delete(field) }
    end

    def run
      check_java
      puts "Running JSLint:\n\n"
      command = "java -cp #{RHINO_JAR_FILE} #{RHINO_JAR_CLASS} #{JSLINT_FILE} #{option_string} #{@file_list.join(' ')}"
      success = system(command)
      raise LintCheckFailure, "JSLint test failed." unless success
    end


    private

    def option_string
      @config.map { |k, v| "#{k}=#{v.inspect}" }.join(',')
    end

    def check_java
      unless @java_ok
        java_test = %x(java -cp #{TEST_JAR_FILE} #{TEST_JAR_CLASS})
        if java_test.strip == "OK"
          @java_ok = true
        else
          raise NoJavaException, "Please install Java before running JSLint."
        end
      end
    end

    def files_matching_paths(options, field)
      path_list = options[field] || @config[field.to_s] || []
      file_list = path_list.map { |p| Dir[p] }.flatten
      Utils.unique_files(file_list)
    end

  end

end
