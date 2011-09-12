require 'jslint'
require 'fakefs'

module JSLint::Utils
  # disable logging to stdout
  def self.xprint(x) ; end
  def self.xputs(x) ; end
end

module Rails
  class Railtie
    def self.rake_tasks
    end
  end
end

module FileUtils
  def copy(*args)
    cp(*args)
  end
end

module FakeFS
  class File
    def self.identical?(file1, file2)
      File.expand_path(file1) == File.expand_path(file2)
    end
  end
end

module SpecHelper
  def create_file(filename, contents)
    contents = YAML.dump(contents) + "\n" unless contents.is_a?(String)
    File.open(filename, "w") { |f| f.print(contents) }
  end

  def create_config(data)
    create_file(JSLint::DEFAULT_CONFIG_FILE, data)
  end
end

RSpec.configure do |config|
  config.include SpecHelper
end
