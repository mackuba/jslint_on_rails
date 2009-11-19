require 'ftools'

class JSLintOnRails

  PATH = File.dirname(__FILE__)
  JAR_FILE = File.expand_path("#{PATH}/rhino.jar")
  TEST_JAR_FILE = File.expand_path("#{PATH}/test.jar")
  JAR_CLASS = "org.mozilla.javascript.tools.shell.Main"
  JSLINT_FILE = File.expand_path("#{PATH}/jslint.js")
  DEFAULT_CONFIG_FILE = File.expand_path("#{PATH}/../jslint.yml")
  CUSTOM_CONFIG_FILE = File.expand_path("#{PATH}/../../../../config/jslint.yml")

  def self.run_lint(paths = nil)
    puts "Running JSLint:\n\n"
    default_config = YAML.load_file(DEFAULT_CONFIG_FILE)
    custom_config = YAML.load_file(CUSTOM_CONFIG_FILE) rescue {}
    config = default_config.merge(custom_config)
    paths ||= ENV['paths'] && ENV['paths'].split(/,/)
    paths ||= config.delete("paths")
    option_string = config.map { |k, v| "#{k}=#{v.inspect}" }.join(',')
    file_list = paths.map { |p| Dir[p] }.flatten
    total_errors = 0

    if %x(java -cp #{TEST_JAR_FILE} Test).strip != "OK"
      raise "Error: please install Java before running JSLint."
    end

    success = system("java -cp #{JAR_FILE} #{JAR_CLASS} #{JSLINT_FILE} #{option_string} #{file_list.join(" ")}")
    raise "JSLint test failed." unless success
  end

  def self.copy_config_file
    print "Copying default config file... "
    if File.exists?(CUSTOM_CONFIG_FILE)
      puts "\n\nWarning: file config/jslint.yml exists, so it won't be overwritten. " +
           "You can copy it manually from vendor/plugins/jslint_on_rails if you want to reset it."
    else
      File.copy(DEFAULT_CONFIG_FILE, CUSTOM_CONFIG_FILE)
      puts "OK."
    end
  end

  def self.remove_config_file
    print "Removing config file... "
    if File.exists?(CUSTOM_CONFIG_FILE) && File.file?(CUSTOM_CONFIG_FILE)
      if File.read(CUSTOM_CONFIG_FILE) == File.read(DEFAULT_CONFIG_FILE)
        File.delete(CUSTOM_CONFIG_FILE)
        puts "OK."
      else
        puts "File was modified, so it won't be deleted automatically."
      end
    else
      puts "OK (no config file found)."
    end
  end

end
