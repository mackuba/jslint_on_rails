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
