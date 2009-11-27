require 'ftools'

class JSLintOnRails

  PATH = File.dirname(__FILE__)
  JAR_FILE = File.expand_path("#{PATH}/rhino.jar")
  TEST_JAR_FILE = File.expand_path("#{PATH}/test.jar")
  JAR_CLASS = "org.mozilla.javascript.tools.shell.Main"
  JSLINT_FILE = File.expand_path("#{PATH}/jslint.js")
  DEFAULT_CONFIG_FILE = File.expand_path("#{PATH}/../jslint.yml")
  CUSTOM_CONFIG_FILE = File.expand_path("#{PATH}/../../../../config/jslint.yml")

  def self.run_lint(paths = nil, exclude_paths = nil)
    puts "Running JSLint:\n\n"

    default_config = YAML.load_file(DEFAULT_CONFIG_FILE)
    custom_config = YAML.load_file(CUSTOM_CONFIG_FILE) rescue {}
    config = default_config.merge(custom_config)

    included_files = files_matching_paths(paths, config, 'paths')
    excluded_files = files_matching_paths(exclude_paths, config, 'exclude_paths')
    file_list = exclude_files(included_files, excluded_files)

    option_string = config.map { |k, v| "#{k}=#{v.inspect}" }.join(',')
    total_errors = 0

    java_test = %x(java -cp #{TEST_JAR_FILE} Test)
    raise "Error: please install Java before running JSLint." unless java_test && java_test.strip == "OK"

    success = system("java -cp #{JAR_FILE} #{JAR_CLASS} #{JSLINT_FILE} #{option_string} #{file_list.join(" ")}")
    raise "JSLint test failed." unless success
  end

  def self.files_matching_paths(path_list, config, option_name)
    paths_from_config = config.delete(option_name)
    path_list ||= (ENV[option_name] && ENV[option_name].split(/,/)) || paths_from_config || []
    file_list = path_list.map { |p| Dir[p] }.flatten
    unique_files(file_list)
  end

  # workaround for a problem with case-insensitive file systems like HFS on Mac
  def self.unique_files(list)
    files = []
    list.each do |entry|
      files << entry unless files.any? { |f| File.identical?(f, entry) }
    end
    files
  end

  # workaround for a problem with case-insensitive file systems like HFS on Mac
  def self.exclude_files(list, excluded)
    list.reject { |entry| excluded.any? { |f| File.identical?(f, entry) }}
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
