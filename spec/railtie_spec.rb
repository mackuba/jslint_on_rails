require 'spec_helper'
require 'jslint/railtie'

describe JSLint::Railtie do
  before :all do
    File.open(JSLint::DEFAULT_CONFIG_FILE, "w") { |f| f.write "foo" }
    JSLint.config_path = "custom_config.yml"
  end

  before :each do
    File.delete(JSLint.config_path) if File.exist?(JSLint.config_path)
  end

  describe "create_example_config" do
    it "should create a config file if it doesn't exist" do
      JSLint::Railtie.create_example_config

      File.exist?(JSLint.config_path).should be_true
      File.read(JSLint.config_path).should == "foo"
    end

    it "should not do anything if config already exists" do
      File.open(JSLint.config_path, "w") { |f| f.write "bar" }

      JSLint::Railtie.create_example_config

      File.exist?(JSLint.config_path).should be_true
      File.read(JSLint.config_path).should == "bar"
    end
  end
end
