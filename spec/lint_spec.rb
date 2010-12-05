require 'spec_helper'

describe JSLint::Lint do

  before :all do
    File.open(JSLint::DEFAULT_CONFIG_FILE, "w") { |f| f.write "color: red\nsize: 5\nshape: circle\n" }
    File.open("custom_config.yml", "w") { |f| f.write "color: blue\nsize: 7\nborder: 2\n" }
    File.open("other_config.yml", "w") { |f| f.write "color: green\nborder: 0\nshape: square" }
    JSLint.config_path = "custom_config.yml"
  end

  def setup_java(lint)
    lint.should_receive(:call_java_with_output).once.and_return("OK")
  end

  def file_list(lint)
    lint.instance_variable_get("@file_list")
  end

  it "should merge default config with custom config from JSLint.config_path" do
    lint = JSLint::Lint.new
    config = lint.instance_variable_get("@config")
    config.should == { 'color' => 'blue', 'size' => 7, 'border' => 2, 'shape' => 'circle' }
  end

  it "should merge default config with custom config given in argument, if available" do
    lint = JSLint::Lint.new :config_path => 'other_config.yml'
    config = lint.instance_variable_get("@config")
    config.should == { 'color' => 'green', 'border' => 0, 'shape' => 'square', 'size' => 5 }
  end

  it "should not pass paths and exclude_paths options to real JSLint" do
    File.open("test.yml", "w") do |f|
      f.write(YAML.dump({ 'paths' => ['a', 'b'], 'exclude_paths' => ['c'], 'debug' => 'true' }))
    end
    lint = JSLint::Lint.new :config_path => 'test.yml'
    config = lint.instance_variable_get("@config")
    config['debug'].should == 'true'
    config['paths'].should be_nil
    config['exclude_paths'].should be_nil
  end

  it "should fail if Java isn't available" do
    lint = JSLint::Lint.new
    lint.should_receive(:call_java_with_output).once.and_return("java: command not found")
    lambda { lint.run }.should raise_error(JSLint::NoJavaException)
  end

  it "should fail if JSLint check fails" do
    lint = JSLint::Lint.new
    setup_java(lint)
    lint.should_receive(:call_java_with_status).once.and_return(false)
    lambda { lint.run }.should raise_error(JSLint::LintCheckFailure)
  end

  it "should not fail if JSLint check passes" do
    lint = JSLint::Lint.new
    setup_java(lint)
    lint.should_receive(:call_java_with_status).once.and_return(true)
    lambda { lint.run }.should_not raise_error
  end

  it "should only do Java check once" do
    lint = JSLint::Lint.new
    setup_java(lint)
    lint.should_receive(:call_java_with_status).twice.and_return(true)
    lambda do
      lint.run
      lint.run
    end.should_not raise_error(JSLint::NoJavaException)
  end

  it "should pass comma-separated option string to JSLint" do
    lint = JSLint::Lint.new
    lint.instance_variable_set("@config", { 'debug' => true, 'semicolons' => false, 'linelength' => 120 })
    setup_java(lint)
    param_string = ""
    lint.
      should_receive(:call_java_with_status).
      once.
      with(an_instance_of(String), an_instance_of(String), an_instance_of(String)).
      and_return { |a, b, c| param_string = c; true }
    lint.run
    param_string.should =~ /semicolons=false/
    param_string.should =~ /linelength=120/
    param_string.should =~ /debug=true/
  end

  it "should pass space-separated list of files to JSLint" do
    lint = JSLint::Lint.new
    lint.instance_variable_set("@file_list", ['app.js', 'test.js', 'jquery.js'])
    setup_java(lint)
    lint.
      should_receive(:call_java_with_status).
      once.
      with(an_instance_of(String), an_instance_of(String), /app\.js test\.js jquery\.js$/).
      and_return(true)
    lint.run
  end

  describe "file lists" do
    before :each do
      JSLint::Utils.stub!(:exclude_files).and_return { |inc, exc| inc - exc }
      JSLint::Utils.stub!(:unique_files).and_return { |files| files.uniq }
    end

    before :all do
      @files = ['test/app.js', 'test/lib.js', 'test/utils.js', 'test/vendor/jquery.js', 'test/vendor/proto.js']
      @files.each { |fn| File.open(fn, "w") { |f| f.write("alert()") }}
      @files = @files.map { |fn| File.expand_path(fn) }
    end

    it "should calculate a list of files to test" do
      lint = JSLint::Lint.new :paths => ['test/**/*.js']
      file_list(lint).should == @files

      lint = JSLint::Lint.new :paths => ['test/a*.js', 'test/**/*r*.js']
      file_list(lint).should == [@files[0], @files[3], @files[4]]

      lint = JSLint::Lint.new :paths => ['test/a*.js', 'test/**/*r*.js'], :exclude_paths => ['**/*q*.js']
      file_list(lint).should == [@files[0], @files[4]]

      lint = JSLint::Lint.new :paths => ['test/**/*.js'], :exclude_paths => ['**/*.js']
      file_list(lint).should == []

      lint = JSLint::Lint.new :paths => ['test/**/*.js', 'test/**/a*.js', 'test/**/p*.js']
      file_list(lint).should == @files

      File.open("new.yml", "w") { |f| f.write(YAML.dump({ 'paths' => ['test/vendor/*.js'] })) }

      lint = JSLint::Lint.new :config_path => 'new.yml', :exclude_paths => ['**/proto.js']
      file_list(lint).should == [@files[3]]

      lint = JSLint::Lint.new :config_path => 'new.yml', :paths => ['test/l*.js']
      file_list(lint).should == [@files[1]]
    end

    it "should accept :paths and :exclude_paths as string instead of one-element array" do
      lambda do
        lint = JSLint::Lint.new :paths => 'test/*.js', :exclude_paths => 'test/lib.js'
        file_list(lint).should == [@files[0], @files[2]]
      end.should_not raise_error
    end

    it "should ignore empty files" do
      File.open("test/empty.js", "w") { |f| f.write("") }
      File.open("test/full.js", "w") { |f| f.write("qqq") }

      lint = JSLint::Lint.new :paths => ['test/*.js']
      file_list(lint).should_not include(File.expand_path("test/empty.js"))
      file_list(lint).should include(File.expand_path("test/full.js"))
    end
  end

end
