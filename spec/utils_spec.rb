require 'spec_helper'

describe JSLint::Utils do

  JSU = JSLint::Utils

  before :all do
    File.open(JSLint::DEFAULT_CONFIG_FILE, "w") { |f| f.puts "default config file" }
  end

  it "should have a config_path setting" do
    JSLint.config_path = 'some/path'
    JSLint.config_path.should == 'some/path'
  end

  describe "paths_from_command_line" do
    it "should extract an array of paths from command line argument" do
      ENV['test_arg'] = 'one,two,three'
      JSU.paths_from_command_line('test_arg').should == ['one', 'two', 'three']
    end
  
    it "should also work if the argument name is given in uppercase" do
      ENV['TEST_ARG'] = 'ruby,python,js'
      JSU.paths_from_command_line('test_arg').should == ['ruby', 'python', 'js']
    end
  
    it "should return nil if the argument isn't set" do
      JSU.paths_from_command_line('crash').should be_nil
    end
  
    after :each do
      ENV['test_arg'] = nil
      ENV['TEST_ARG'] = nil
    end
  end
  
  describe "load_config_file" do
  
    before :all do
      File.open("sample.yml", "w") { |f| f.puts("framework: rails") }
      Dir.mkdir("tmp")
    end
  
    it "should load a YAML file if it can be read" do
      JSU.load_config_file("sample.yml").should == { 'framework' => 'rails' }
    end
  
    it "should return an empty hash if file name is nil" do
      JSU.load_config_file(nil).should == {}
    end
  
    it "should return an empty hash if file doesn't exist" do
      JSU.load_config_file("crack.exe").should == {}
    end
  
    it "should return an empty hash if file is not a file" do
      JSU.load_config_file("tmp").should == {}
    end
  
    it "should return an empty hash if file is not readable" do
      File.should_receive(:readable?).once.with("sample.yml").and_return(false)
      JSU.load_config_file("sample.yml").should == {}
    end
  end

  describe "unique and exclude" do
    def set_identical(file1, file2, value)
      File.should_receive(:identical?).with(file1, file2).once.and_return(value)
    end

    it "should remove duplicate files from a list" do
      set_identical('config.yml',  'lib/../config.yml', true)
      set_identical('config.yml',  'Rakefile',          false)
      set_identical('config.yml',  'Config.yml',        true)
      unique = JSU.unique_files(['config.yml', 'lib/../config.yml', 'Rakefile', 'Config.yml'])
      unique.should == ['config.yml', 'Rakefile']
    end

    it "should subtract files on the second list from the first list" do
      set_identical('RaKeFiLe',    'config.yml', false)
      set_identical('wtf',         'config.yml', false)
      set_identical('Config.yml',  'config.yml', true)
      set_identical('RaKeFiLe',    'Rakefile',   true)
      set_identical('RaKeFiLe',    'Gemfile',    false)
      set_identical('wtf',         'Gemfile',    false)
      set_identical('Config.yml',  'Gemfile',    false)
      included = JSU.exclude_files(['config.yml', 'Rakefile', 'Gemfile'], ['RaKeFiLe', 'wtf', 'Config.yml'])
      included.should == ['Gemfile']
    end
  end

  describe "copy_config_file" do
    it "throw an error if config path isn't set" do
      JSLint.config_path = nil
      lambda { JSLint::Utils.copy_config_file }.should raise_error(ArgumentError)
    end

    it "should copy default config to config_path" do
      JSLint.config_path = "newfile.yml"
      File.should_receive(:copy).with(JSLint::DEFAULT_CONFIG_FILE, "newfile.yml")
      JSLint::Utils.copy_config_file
    end

    it "should not overwrite the file if it exists" do
      JSLint.config_path = "newfile2.yml"
      File.open("newfile2.yml", "w") { |f| f.write("qwe") }
      File.should_not_receive(:copy)
      JSLint::Utils.copy_config_file
    end
  end

  describe "remove_config_file" do
    it "throw an error if config path isn't set" do
      JSLint.config_path = nil
      lambda { JSLint::Utils.remove_config_file }.should raise_error(ArgumentError)
    end

    it "should remove the file if it's identical to default one" do
      JSLint.config_path = "newfile3.yml"
      File.open("newfile3.yml", "w") { |f| f.puts("default config file") }
      File.exists?("newfile3.yml").should be_true
      JSLint::Utils.remove_config_file
      File.exists?("newfile3.yml").should be_false
    end

    it "should not remove the file if it's not identical to default one" do
      JSLint.config_path = "newfile4.yml"
      File.open("newfile4.yml", "w") { |f| f.puts("something's changed") }
      File.exists?("newfile4.yml").should be_true
      JSLint::Utils.remove_config_file
      File.exists?("newfile4.yml").should be_true
    end

    it "should not remove the file if it doesn't exist" do
      JSLint.config_path = "this_doesnt_exist.yml"
      lambda { JSLint::Utils.remove_config_file }.should_not raise_error
    end

    it "should not remove the file if it's not a file" do
      Dir.mkdir("public")
      JSLint.config_path = "public"
      lambda { JSLint::Utils.remove_config_file }.should_not raise_error
      File.exist?("public").should be_true
      File.directory?("public").should be_true
    end
  end

end
