require 'spec_helper'

describe JSLint::Lint do

  JSLint::Lint.class_eval do
    attr_reader :config, :file_list
  end

  before :all do
    create_config 'color' => 'red', 'size' => 5, 'shape' => 'circle'
    create_file 'custom_config.yml', 'color' => 'blue', 'size' => 7, 'border' => 2
    create_file 'other_config.yml', 'color' => 'green', 'border' => 0, 'shape' => 'square'
    JSLint.config_path = "custom_config.yml"
  end

  def setup_java(lint)
    lint.should_receive(:call_java_with_output).once.and_return("OK")
  end

  it "should merge default config with custom config from JSLint.config_path" do
    lint = JSLint::Lint.new
    lint.config.should == { 'color' => 'blue', 'size' => 7, 'border' => 2, 'shape' => 'circle' }
  end

  it "should merge default config with custom config given in argument, if available" do
    lint = JSLint::Lint.new :config_path => 'other_config.yml'
    lint.config.should == { 'color' => 'green', 'border' => 0, 'shape' => 'square', 'size' => 5 }
  end

  it "should convert predef to string if it's an array" do
    create_file 'predef.yml', 'predef' => ['a', 'b', 'c']

    lint = JSLint::Lint.new :config_path => 'predef.yml'
    lint.config['predef'].should == "a,b,c"
  end

  it "should accept predef as string" do
    create_file 'predef.yml', 'predef' => 'd,e,f'

    lint = JSLint::Lint.new :config_path => 'predef.yml'
    lint.config['predef'].should == "d,e,f"
  end

  it "should not pass paths and exclude_paths options to real JSLint" do
    create_file 'test.yml', 'paths' => ['a', 'b'], 'exclude_paths' => ['c'], 'debug' => 'true'

    lint = JSLint::Lint.new :config_path => 'test.yml'
    lint.config['debug'].should == 'true'
    lint.config['paths'].should be_nil
    lint.config['exclude_paths'].should be_nil
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

  it "should pass an ampersand-separated option string to JSLint" do
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

    option_string = param_string.split(/\s+/).detect { |p| p =~ /linelength/ }
    eval(option_string).split('&').sort.should == ['debug=true', 'linelength=120', 'semicolons=false']
  end

  it "should escape $ in option string when passing it to Java/JSLint" do
    lint = JSLint::Lint.new
    lint.instance_variable_set("@config", { 'predef' => 'window,$,Ajax,$app,Request' })
    setup_java(lint)
    param_string = ""
    lint.
      should_receive(:call_java_with_status).
      once.
      with(an_instance_of(String), an_instance_of(String), /window,\\\$,Ajax,\\\$app,Request/).
      and_return(true)
    lint.run
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
      @files.each { |fn| create_file(fn, "alert()") }
      @files = @files.map { |fn| File.expand_path(fn) }
    end

    it "should calculate a list of files to test" do
      lint = JSLint::Lint.new :paths => ['test/**/*.js']
      lint.file_list.should == @files

      lint = JSLint::Lint.new :paths => ['test/a*.js', 'test/**/*r*.js']
      lint.file_list.should == [@files[0], @files[3], @files[4]]

      lint = JSLint::Lint.new :paths => ['test/a*.js', 'test/**/*r*.js'], :exclude_paths => ['**/*q*.js']
      lint.file_list.should == [@files[0], @files[4]]

      lint = JSLint::Lint.new :paths => ['test/**/*.js'], :exclude_paths => ['**/*.js']
      lint.file_list.should == []

      lint = JSLint::Lint.new :paths => ['test/**/*.js', 'test/**/a*.js', 'test/**/p*.js']
      lint.file_list.should == @files

      create_file 'new.yml', 'paths' => ['test/vendor/*.js']

      lint = JSLint::Lint.new :config_path => 'new.yml', :exclude_paths => ['**/proto.js']
      lint.file_list.should == [@files[3]]

      lint = JSLint::Lint.new :config_path => 'new.yml', :paths => ['test/l*.js']
      lint.file_list.should == [@files[1]]
    end

    it "should accept :paths and :exclude_paths as string instead of one-element array" do
      lambda do
        lint = JSLint::Lint.new :paths => 'test/*.js', :exclude_paths => 'test/lib.js'
        lint.file_list.should == [@files[0], @files[2]]
      end.should_not raise_error
    end

    it "should ignore empty files" do
      create_file 'test/empty.js', ''
      create_file 'test/full.js', 'qqq'

      lint = JSLint::Lint.new :paths => ['test/*.js']
      lint.file_list.should_not include(File.expand_path("test/empty.js"))
      lint.file_list.should include(File.expand_path("test/full.js"))
    end
  end

end
