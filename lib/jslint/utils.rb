require 'fileutils'
require 'yaml'

module JSLint

  VERSION = "1.0.6"
  DEFAULT_CONFIG_FILE = File.expand_path(File.dirname(__FILE__) + "/config/jslint.yml")

  class << self
    attr_accessor :config_path
  end

  module Utils
    class << self

      def xprint(txt)
        print txt
      end

      def xputs(txt)
        puts txt
      end

      def load_config_file(file_name)
        if file_name && File.exists?(file_name) && File.file?(file_name) && File.readable?(file_name)
          YAML.load_file(file_name)
        else
          {}
        end
      end

      # workaround for a problem with case-insensitive file systems like HFS on Mac
      def unique_files(list)
        files = []
        list.each do |entry|
          files << entry unless files.any? { |f| File.identical?(f, entry) }
        end
        files
      end

      # workaround for a problem with case-insensitive file systems like HFS on Mac
      def exclude_files(list, excluded)
        list.reject { |entry| excluded.any? { |f| File.identical?(f, entry) }}
      end

      #workaround for pulling :javascript sections out of haml files and temp storing them so we can run jslint on the javascript
      def haml_files_with_javascript(list)
        javascript_haml_files = []

        matching_files.each do |file|
           #got the files. now check to see if they have :javascript tags
           process_file = File.new(file, 'r')

           while l = process_file.gets do
             if l =~ /:javascript/i
               javascript_haml_files << file
               next
             end
           end

           process_file.close
         end

        javascript_haml_files = []
      end

      def extract_and_store_haml_javascript(file_list)
        tmp_javascript_files = []
        javascript_pull = Regexp.new(/:javascript(.*)/i)
        #need to caputre the number of \s in the front of :javascript and use it determine if i reject lines

        javascript_haml_files.each do |file|
          tmp_file_handle = "tmp/jslint/#{file}.js"
          tmp_javascript_files << tmp_file_handle

          dir_path = tmp_file_handle.split('/')
          dir_path.delete(dir_path.last)
          dir_path = dir_path.join('/')

          File.delete(tmp_file_handle) if File.exist?(tmp_file_handle)
          FileUtils.mkdir_p(dir_path)

          s = IO.read(file).split(':javascript').last
          out =  File.open(tmp_file_handle, "w")

          s.split('\n').each do |line|
            next if line =~ /\s+\//i
            out.puts line
          end

          out.close
        end

        return tmp_javascript_files
      end

      def paths_from_command_line(field)
        argument = ENV[field] || ENV[field.upcase]
        argument && argument.split(/,/)
      end

      def copy_config_file
        raise ArgumentError, "Please set JSLint.config_path" if JSLint.config_path.nil?
        xprint "Creating example JSLint config file in #{File.expand_path(JSLint.config_path)}... "
        if File.exists?(JSLint.config_path)
          xputs "\n\nWarning: config file exists, so it won't be overwritten. " +
                "You can copy it manually from the jslint_on_rails directory if you want to reset it."
        else
          FileUtils.copy(JSLint::DEFAULT_CONFIG_FILE, JSLint.config_path)
          xputs "done."
        end
      end

      def remove_config_file
        raise ArgumentError, "Please set JSLint.config_path" if JSLint.config_path.nil?
        xprint "Removing config file... "
        if File.exists?(JSLint.config_path) && File.file?(JSLint.config_path)
          if File.read(JSLint.config_path) == File.read(JSLint::DEFAULT_CONFIG_FILE)
            File.delete(JSLint.config_path)
            xputs "OK."
          else
            xputs "File was modified, so it won't be deleted automatically."
          end
        else
          xputs "OK (no config file found)."
        end
      end

    end
  end
end
