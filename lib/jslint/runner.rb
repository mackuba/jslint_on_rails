require 'jslint/config'
require 'jslint/engine'
require 'jslint/errors'
require 'jslint/utils'

module JSLint
  class Runner

    # available options:
    # :paths => [list of paths...]
    # :exclude_paths => [list of exluded paths...]
    # :config_path => path to custom config file (can be set via JSLint.config_path too)

    def initialize(params = {})
      @config = Config.new(params)
      @engine = Engine.new(params[:config_path])
    end

    def run
      puts "Running JSLint via #{@engine.js_engine_name}:\n\n"

      errors = @config.files.map { |f| process_file(f) }

      if errors.length == 0
        puts "\nNo JS errors found."
      else
        puts "\nFound #{Utils.pluralize(errors.length, 'error')}."
        raise LintCheckFailure, "JSLint test failed."
      end
    end


    private

    def process_file(filename)
      print "checking #{filename}... "
      errors = []

      if File.exist?(filename)
        source = File.read(filename)
        errors = @engine.check_file(source)

        if errors.length == 0
          puts "OK"
        else
          puts Utils.pluralize(errors.length, "error") + ":\n"

          errors.each do |error|
            puts "Lint at line #{error.line} character #{error.character}: #{error.reason}"

            if error.evidence
              evidence = error.evidence.gsub(/^\s*(\S*(\s+\S+)*)\s*$/) { $1 }
              puts evidence
            end

            puts
          end
        end
      else
        puts "Error: couldn't open file."
      end

      errors
    end

  end

  # backwards compatibility
  alias Lint Runner
end
