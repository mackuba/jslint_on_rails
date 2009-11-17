class JSLintOnRails

  PATH = File.dirname(__FILE__)
  JAR_FILE = "#{PATH}/rhino-js.jar"
  JAR_CLASS = "org.mozilla.javascript.tools.shell.Main"
  JSLINT_FILE = "#{PATH}/jslint.js"

  # see http://www.jslint.com/lint.html#options for more details explanations
  
  DEFAULT_OPTIONS = {
    :adsafe =>   false,   # true if ADsafe rules should be enforced. See http://www.ADsafe.org/
    :bitwise =>  true,    # true if bitwise operators should not be allowed
    :browser =>  false,   # true if the standard browser globals should be predefined
    :cap =>      false,   # true if upper case HTML should be allowed
    :newcap =>   true,    # true if Initial Caps must be used with constructor functions
    :css =>      true,    # true if CSS workarounds should be tolerated
    :debug =>    true,    # true if debugger statements should be allowed (set to false before going into production)
    :eqeqeq =>   true,    # true if === should be required (for ALL comparisons)
    :evil =>     false,   # true if eval should be allowed
    :forin =>    false,   # true if unfiltered 'for in' statements should be allowed
    :fragment => true,    # true if HTML fragments should be allowed
    :immed =>    true,    # true if immediate function invocations must be wrapped in parens
    :indent =>   2,       # The number of spaces used for indentation (default is 4)
    :laxbreak => false,   # true if statement breaks should not be checked
    :maxerr =>   50,      # The maximum number of warnings reported (default is 50)
    :nomen =>    false,   # true if names should be checked for initial underbars
    :on =>       false,   # true if HTML event handlers should be allowed
    :onevar =>   false,   # true if only one var statement per function should be allowed
    :passfail => false,   # true if the scan should stop on first error
    :plusplus => false,   # true if ++ and -- should not be allowed
    :predef =>   '',      # An array of strings, the names of predefined global variables
    :regexp =>   false,   # true if . should not be allowed in RegExp literals
    :rhino =>    true,    # true if the Rhino environment globals should be predefined
    :safe =>     false,   # true if the safe subset rules are enforced. These rules are used by ADsafe.
    :sidebar =>  false,   # true if the Windows Sidebar Gadgets globals should be predefined
    :strict =>   false,   # true if the ES5 "use strict"; pragma is required
    :sub =>      true,    # true if subscript notation may be used for expressions better expressed in dot notation
    :undef =>    true,    # true if variables must be declared before used
    :white =>    false,   # true if strict whitespace rules apply
    :widget =>   false,   # true if the Yahoo Widgets globals should be predefined
  }

  cattr_accessor :options

  def self.lint_files(file_list)
    puts "Running JSLint:"
    option_string = DEFAULT_OPTIONS.merge(options || {}).map { |k, v| "#{k}=#{v}" }.join(',')
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
