# JSLint on Rails

[![Build Status](https://secure.travis-ci.org/psionides/jslint_on_rails.png)](http://travis-ci.org/psionides/jslint_on_rails)

**JSLint on Rails** is a Ruby library which lets you run
the [JSLint JavaScript code checker](https://github.com/douglascrockford/JSLint) on your Javascript code easily.


## Requirements

* Ruby 1.8.7 or 1.9.2+
* Javascript engine compatible with [execjs](https://github.com/sstephenson/execjs) (on Mac and Windows it's provided by the OS)
* JSON engine compatible with [multi_json](https://github.com/intridea/multi_json) (included in Ruby 1.9, on 1.8 use e.g. [json gem](http://rubygems.org/gems/json))
* should work with (but doesn't require) Rails 2.x and 3.x


## Installation

To use JSLint in Rails 3 you just need to do one thing:

* add `gem 'jslint_on_rails'` to bundler's Gemfile

In Rails 2 and other frameworks JSLint on Rails can't be loaded automatically using a Railtie, so you have to load it explicitly. The procedure in this case is:

* install the gem in your application using whatever technique is recommended for your framework (e.g. using bundler,
or by installing the gem manually with `gem install jslint_on_rails` and loading it with `require 'jslint'`)
* in your Rakefile, add a line to load the JSLint tasks:

        require 'jslint/tasks'

## Configuration

It's strongly recommended that you create your own copy of the JSLint config file provided by the gem and tweak it to suit your preferences. To create a new config file from the template in your config directory, call this rake task:

    [bundle exec] rake jslint:copy_config

This will create a config file at `config/jslint.yml` listing all available options. If for some reason you'd like to put the config file at a different location, set the `config_path` variable somewhere in your Rakefile:

    JSLint.config_path = "config/lint.yml"

There are two things you can change in the config file:

* define which Javascript files are checked by default; you'll almost certainly want to change that, because the default
is `public/javascripts/**/*.js` which means all Javascript files, and you probably don't want JSLint to check entire
jQuery, Prototype or whatever other libraries you use - so change this so that only your scripts are checked (you can
put multiple entries under "paths:" and "exclude_paths:")
* enable or disable specific checks - I've set the defaults to what I believe is reasonable,
but what's reasonable for me may not be reasonable for you


## Running

To start the check, run the rake task:

    [bundle exec] rake jslint

You will get a result like this (if everything goes well):

    Running JSLint:
    
    checking public/javascripts/Event.js... OK
    checking public/javascripts/Map.js... OK
    checking public/javascripts/Marker.js... OK
    checking public/javascripts/Reports.js... OK
    
    No JS errors found.

If anything is wrong, you will get something like this instead:

    Running JSLint:
    
    checking public/javascripts/Event.js... 2 errors:
    
    Lint at line 24 character 15: Use '===' to compare with 'null'.
    if (a == null && b == null) {
    
    Lint at line 72 character 6: Extra comma.
    },
    
    checking public/javascripts/Marker.js... 1 error:
    
    Lint at line 275 character 27: Missing radix parameter.
    var x = parseInt(mapX);
    
    
    Found 3 errors.
    rake aborted!
    JSLint test failed.

If you want to test specific file or files (just once, without modifying the config), you can pass paths to include
and/or paths to exclude to the rake task:

    rake jslint paths=public/javascripts/models/*.js,public/javascripts/lib/*.js exclude_paths=public/javascripts/lib/jquery.js

For the best effect, you should include JSLint check in your Continuous Integration build - that way you'll get
immediate notification when you've committed JS code with errors.


## Running automatically with Guard

If you want to run JSLint on Rails automatically everytime you save a JS file, check out the
[guard-jslint-on-rails](https://github.com/wireframe/guard-jslint-on-rails) gem by Ryan Sonnek.


## Running from your code

If you would prefer to write your own rake task to run JSLint, you can create and execute the JSLint object manually:

    require 'jslint'
    
    lint = JSLint::Lint.new(
      :paths => ['public/javascripts/**/*.js'],
      :exclude_paths => ['public/javascripts/vendor/**/*.js'],
      :config_path => 'config/jslint.yml'
    )
    
    lint.run


## Additional options

I've added some additional options to JSLint to get rid of some warnings which I thought didn't make sense. They're all
disabled by default, but feel free to enable any or all of them if you feel abused by JSLint.

Here's a documentation for all the extra options:


### lastsemic

If set to true, this will ignore warnings about missing semicolon after a statement, if the statement is the last one in
a block or function, and the whole block is on the same line. I've added this because I like to omit the semicolon in
one-liner anonymous functions, in situations like this:

    var ids = $$('.entry').map(function(e) { return e.id });

Note: in versions up to 1.0.3, this option also disabled the warning in blocks that span multiple lines, but I've
changed that in 1.0.4, because removing a last semicolon in a multi-line block doesn't really affect the readability
(while removing the only semicolon in a one-liner like above does, IMHO).


### newstat

Allows you to use a call to 'new' as a whole statement, without assigning the result anywhere. Sometimes you want to
create an instance of a class, but you don't need to assign it anywhere - the call to constructor starts the action
automatically. This includes calls like `new Ajax.Request(...)` or `new Effect.Highlight(...)` used when working with
Prototype and Scriptaculous.


### statinexp

JSLint has a warning that says "Expected an assignment or function call and instead saw an expression" - you get it
when you write an expression and you don't use it for anything, like if you wrote such line:

    $$('.entry').length;

Just checking the length without assigning it anywhere or passing to any function doesn't make any sense, so it's good
that JSLint complains. However, there are some cases where the code makes perfect sense, but JSLint still thinks it
doesn't. Examples:

    element && element.show();  // call show only if element is not null
    selected ? element.show() : element.hide();  // more readable than if & else with brackets

So I've tweaked the code that creates this warning so that it doesn't print it if the code makes sense. Specifically:

* expressions joined with && or || are accepted if the last one in the line is a statement
* expressions with ?: are accepted if both alternatives (before and after the colon) are statements


## Version 2.0 and JSHint

Some people have asked about [JSHint](http://jshint.com) support (some have even made forks replacing JSLint with JSHint). I like the idea of a less strict lint giving the user more control; the reason I haven't integrated JSHint yet is because I want the gem to provide both JSLint and JSHint and let you choose which engine you want to use. The thing is, I can't do that easily because their option sets have diverged - a few options have been changed in JSLint since JSHint was forked off from it, and JSHint has changed or added some other options. There was even [a plan](https://github.com/jshint/jshint/issues/166) to completely redesign the option system in JSHint. So I've decided to hold off the integration until I can be sure that the option sets won't be completely changed again. I'm hoping this might happen as a part of the [JSHint Next](https://github.com/jshint/jshint-next) project, but I don't know what the timeline is.

I haven't been updating JSLint for the same reason - some options have changed there and I'd rather wait until I can update everything together at the same time. If you're impatient, check out some of the [forks that use JSHint](https://github.com/psionides/jslint_on_rails/network); some of them have even been released as gems (e.g. see [jshint\_on\_rails](https://rubygems.org/gems/jshint_on_rails)) - although as far as I know, none of them have adapted the config file template to match JSHint's option set.

Another thing that's planned for 2.0, whenever that happens, is a redesign of the Javascript runner code to make it possible to use other ways of running Javascript - probably using [execjs](https://github.com/sstephenson/execjs).


## Credits

* JSLint on Rails was created by [Jakub Suder](http://psionides.jogger.pl), licensed under MIT License
* JSLint was created by [Douglas Crockford](http://jslint.com)
