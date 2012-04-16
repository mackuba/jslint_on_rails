Version 1.1.1 (16.04.2012)

* fixed issue with jslint:copy_config task

Version 1.1 (09.04.2012)

* removed support for installing as a Rails plugin
* doesn't auto-generate jslint.yml if it doesn't exist (create one explicitly using the rake task if you want)
* no need to set JSLint.config_path (if you aren't using the Railtie) if the file is in the default location

Version 1.0.7 (12.09.2011)

* fixed problem with local options from one file being applied to all subsequent files

Version 1.0.6 (19.02.2011)

* escape $ in predef line to prevent Bash for interpreting it
* predef can be passed as a YAML array

Version 1.0.5 (08.01.2011)

* options passed on the command line to JSLint are joined with "&" to fix the "predef" option
* load YAJL module explicitly (in some environments it may not be loaded automatically)

Version 1.0.4 (05.12.2010)

* bundler should be able to load the gem without :require
* added a Railtie to make things simpler in Rails 3
* don't print any warnings if tested JS file is empty
* lastsemic option will now not work if the missing semicolon is on a different line than the end bracket (so it only
  makes sense for inline one-liner functions)
* updated JSLint to version from 2010-11-27 (adds some new warnings about comparing variables with empty string using
  "==")

Version 1.0.3 (11.06.2010)

* Ruby 1.9 compatibility fixes
* 'es5' option is disabled by default

Version 1.0.2 (10.04.2010)

* Rails 3 compatibility fixes
* updated JSLint to version from 2010-04-06
* refactoring, added specs

Version 1.0.0 (18.12.2009)

* first gem release
