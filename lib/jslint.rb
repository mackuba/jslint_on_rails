require 'jslint/errors'
require 'jslint/utils'
require 'jslint/lint'

if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'jslint/railtie'
end
