class JSLintOnRails

  PATH = File.dirname(__FILE__)
  JAR_FILE = "#{PATH}/rhino-js.jar"
  JAR_CLASS = "org.mozilla.javascript.tools.shell.Main"
  JSLINT_FILE = "#{PATH}/jslint.js"
  DEFAULT_CONFIG_FILE = "#{PATH}/../jslint.yml"
  CUSTOM_CONFIG_FILE = "#{PATH}/../../../../config/jslint.yml"

  def self.lint_files(paths = nil)
    puts "Running JSLint:"
    default_config = YAML.load_file(DEFAULT_CONFIG_FILE)
    custom_config = YAML.load_file(CUSTOM_CONFIG_FILE) rescue {}
    config = default_config.merge(custom_config)
    paths ||= config.delete("paths")
    option_string = config.map { |k, v| "#{k}=#{v.inspect}" }.join(',')
    file_list = paths.map { |p| Dir[p] }.flatten
    total_errors = 0

    file_list.each do |file|
      # TODO check if java is available
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

end
