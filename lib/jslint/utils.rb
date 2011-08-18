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
        javascript_haml_files_and_depth = []
        javascript_tag = Regexp.new(/((\s?)+):javascript/i)

        list.each do |file|
           #got the files. now check to see if they have :javascript tags
           process_file = File.new(file, 'r')

           while l = process_file.gets do
             if l =~ /:javascript/i
               depth = l.match(javascript_tag)[1].size
               javascript_haml_files_and_depth << {:file => file, :depth => depth}
               next
             end
           end

           process_file.close
         end

        javascript_haml_files_and_depth
      end


      #TODO split into 3 functions
      #file create and split !! DONE
      #file eval and replacment of ruby variables
      #file check on depth and drop if deeper then depth
      def extract_and_store_haml_javascript(file_and_depth)
        tmp_javascript_files = []
        #hash of replaced ruby variables and new values
        replacement_hash = {}

        indent_depth = Regexp.new(/((\s?)+)\S/i)
        #need to caputre the number of \s in the front of :javascript and use it determine if i reject lines
        file_and_depth.each do |ele|
          file = ele[:file]
          depth_of_tag = ele[:depth]

          tmp_file_handle = "tmp/jslint/#{file}.js"
          tmp_javascript_files << tmp_file_handle

          tmp_file = create_tmp_javascript_file(file, tmp_file_handle)

          lines = File.new(tmp_file,"r")
          out = File.new(tmp_file_handle, "w")

          while (line = lines.gets)
            #Drops commented lines
            next if line =~ /\A\s+\//i

            #drops blank lines
            next if line.strip.empty?

            #replace ruby injections
            line, replacement_hash = find_and_replace_ruby_injection(line, replacement_hash)

            #now check to see how many indents. If less then the number :javascript was endnted drop them
            #we have the indent for the :javascript
            #if indent is <= depth_of_tag drop the rest of the file
            #FIXME Known bug. Will only eval first :javascript block in HAML file
            break if line.match(indent_depth)[1].size < depth_of_tag + 2

            out.puts line
          end

          out.close
        end

        return tmp_javascript_files
      end

      def find_and_replace_ruby_injection(line, replacements)
        ruby_injection = Regexp.new(/#\{([@|\w|\.|:|\_|\(|\)]+)\}/i)
        #{profile.avatar_geometry(:large).width}
        #{@avatar_owner.avatar_geometry(:large).width}
        # byprice = #{@businesses.sort_by{|b| b.instant_bid(params[:task])}.collect{|b| "business_#{b.id}"}.to_json}
        # byrank = #{@businesses.sort_by{|b| -b.normalized_avg_rating}.collect{|b| "business_#{b.id}"}.to_json}

        to_replace = {}

        line.scan(ruby_injection) do |injected_ruby|
          injected = injected_ruby.first.gsub(/\W/i, '_')
          replacements[injected_ruby.first] ||= "#{injected}_jslint"

          to_replace['#{'+injected_ruby.first+'}']  = replacements[injected_ruby.first]
        end

        to_replace.each_pair{|k, v| line.gsub!(k, v)}

        #line.gsub!(this_id_gsub, "#{this_id_match[1].gsub(/\W/i, '_')}_jslint_replacement")if this_id_match

        return line, replacements
      end

      def create_tmp_javascript_file(file_name, tmp_file_handle)
        dir_path = tmp_file_handle.split('/')
        dir_path.delete(dir_path.last)
        dir_path = dir_path.join('/')

        File.delete(tmp_file_handle) if File.exist?(tmp_file_handle)
        FileUtils.mkdir_p(dir_path)

        split_file = IO.read(file_name).split(':javascript').last

        out =  File.open("tmp/jslint/overwrite.tmp", "w")
        out.puts split_file
        out.close

        return out.path
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
