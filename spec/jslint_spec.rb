require 'spec_helper'

describe 'jslint.js' do
  before :all do
    File.open(JSLint::DEFAULT_CONFIG_FILE, "w") { |f| f.write "color: red\nsize: 5\nshape: circle\n" }
    File.open("custom_config.yml", "w") { |f| f.write "color: blue\nsize: 7\nborder: 2\n" }
    File.open("other_config.yml", "w") { |f| f.write "color: green\nborder: 0\nshape: square" }
    JSLint.config_path = "custom_config.yml"
  end

  describe "options in comments" do
    before do
      FakeFS.deactivate!
      create_file 'spec-config.yml', 'evil: false'
      create_file 'first.js', "
        /*jslint evil: true*/
        eval('alert(\"muahahahaha\")');
      "
      create_file 'second.js', "
        // I shouldn't be able to do that
        eval('alert(\"muahahahaha\")');
      "
    end

    it "should not apply local options from one file to all subsequent files" do
      lint = JSLint::Lint.new(:paths => ["first.js", "second.js"], :config => 'spec-config.yml')

      # silence stdout from jslint
      lint.instance_eval do
        def system(command)
          `#{command}`
          $? == 0
        end
      end

      expect { lint.run }.to raise_error(JSLint::LintCheckFailure)
    end

    after do
      File.delete('first.js')
      File.delete('second.js')
      File.delete('spec-config.yml')
      FakeFS.activate!
    end
  end
end
