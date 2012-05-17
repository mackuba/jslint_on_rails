require 'jslint/config'
require 'jslint/errors'
require 'execjs'
require 'hashie'
require 'multi_json'

module JSLint
  class Engine
    JSLINT_FILE = File.expand_path("../vendor/jslint.js", __FILE__)

    def initialize(config_path = nil)
      @config = Config.new(:config_path => config_path)
    end

    def check_file(source)
      code = %(
        JSLINT(#{source.inspect}, #{MultiJson.dump(@config.options)});
        return JSLINT.errors;
      )

      Hashie::Mash.new(context.exec(code))
    end

    def js_engine_name
      if js_engine
        js_engine.name
      else
        raise NoEngineException, "No JS engine available"
      end
    end


    private

    def js_engine
      ExecJS.runtime
    end

    def context
      @context ||= ExecJS.compile(File.read(JSLINT_FILE))
    end
  end
end
