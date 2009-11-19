require 'ftools'

class JSLintOnRails

  class NoJavaError < StandardError
  end

  PATH = File.dirname(__FILE__)
  JAR_FILE = File.expand_path("#{PATH}/rhino-js.jar")
  TEST_JAR_FILE = File.expand_path("#{PATH}/test.jar")
  JAR_CLASS = "org.mozilla.javascript.tools.shell.Main"
  JSLINT_FILE = File.expand_path("#{PATH}/jslint.js")
  DEFAULT_CONFIG_FILE = File.expand_path("#{PATH}/../jslint.yml")
  CUSTOM_CONFIG_FILE = File.expand_path("#{PATH}/../../../../config/jslint.yml")

  def self.lint_files(paths = nil)
    puts "Running JSLint:"
    default_config = YAML.load_file(DEFAULT_CONFIG_FILE)
    custom_config = YAML.load_file(CUSTOM_CONFIG_FILE) rescue {}
    config = default_config.merge(custom_config)
    paths ||= config.delete("paths")
    option_string = config.map { |k, v| "#{k}=#{v.inspect}" }.join(',')
    file_list = paths.map { |p| Dir[p] }.flatten
    total_errors = 0

    if %x(java -cp #{TEST_JAR_FILE} Test).strip != "OK"
      puts "\nError: please install Java before running JSLint."
      raise NoJavaError
    end

    file_list.each do |file|
      print "checking #{File.basename(file)}... "
      result = %x(java -cp #{JAR_FILE} #{JAR_CLASS} #{JSLINT_FILE} #{file} #{option_string})
      if result =~ /jslint: No problems found/
        puts "OK"
      else
        errors = result.scan(/Lint at line/).length
        total_errors += errors
        puts "#{errors} error#{errors == 1 ? '' : 's'}:\n\n"
        puts result
      end
    end
    if total_errors == 0
      puts "\nNo JS errors found."
    else
      puts "\nFound #{total_errors} errors, JSLint test failed."
    end
  end

  def self.copy_config_file
    print "Copying default config file... "
    if File.exists?(CUSTOM_CONFIG_FILE)
      puts "\n\nWarning: file config/jslint.yml exists, so it won't be overwritten. " +
           "You can copy it manually from vendor/plugins/jslint_on_rails if you want to reset it."
    else
      File.copy(DEFAULT_CONFIG_FILE, CUSTOM_CONFIG_FILE)
      puts "OK"
    end
  end

  def self.remove_config_file
    print "Removing config file... "
    if File.exists?(CUSTOM_CONFIG_FILE) && File.file?(CUSTOM_CONFIG_FILE)
      if File.read(CUSTOM_CONFIG_FILE) == File.read(DEFAULT_CONFIG_FILE)
        File.delete(CUSTOM_CONFIG_FILE)
        puts "OK"
      else
        puts "File was modified, so it won't be deleted automatically."
      end
    else
      puts "OK (no config file found)"
    end
  end

end
