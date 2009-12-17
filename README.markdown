# JSLint on Rails

**JSLint on Rails** is a Ruby gem and Rails plugin which lets you run
the [JSLint JavaScript code checker](http://jslint.com) on your Javascript code easily.

It can be installed either as a Rails plugin (the recommended method for Rails), or as a gem (for other frameworks).

Note: to run JSLint on Rails, you need to have **Java** available on your machine - it's required because JSLint is
itself written in JavaScript, and is run using the [Rhino](http://www.mozilla.org/rhino) JavaScript engine (written in
Java). Any decent version of Java will do (and by decent I mean 5.0 or later).


## Installation (Rails)

If you use Rails, you can install the library as a plugin - it's less work to set it up this way.
To install the plugin, use this command:

    ./script/plugin install git://github.com/psionides/jslint_on_rails.git

This will create for you a sample `jslint.yml` config file in your config directory.


## Installation (other frameworks)

If you use Merb or some other framework, you need to install JSLint as a Ruby gem (you can do that in Rails too - the
advantage of this method is that it may be easier to update to newer versions later).

To use JSLint as a gem, follow these steps:

* install the gem in your application using whatever technique is recommended for your framework (e.g. using gem
bundler, or just plain old `gem install jslint_on_rails`)
* in your Rakefile, add a line to load the JSLint tasks:

        require 'jslint/tasks'

* below that line, set JSLint's config_path variable to point it to a place where you want your JSLint configuration
file to be kept - for example:

        JSLint.config_path = "config/jslint.yml"
    
* run a rake task which will generate a sample config file for you:

        rake jslint:copy_config


## Installation (custom)

If you wish to write your own rake task to run JSLint, you can create and execute the JSLint object manually:

    require 'jslint'
    lint = JSLint::Lint.new(
      :paths => ['public/javascripts/**/*.js'],
      :exclude_paths => ['public/javascripts/vendor/**/*.js'],
      :config_path => 'config/jslint.yml'
    )
    lint.run


## Configuration

Whatever method you use for installation, a YAML config file should be created for you. In this file, you can:

* define which Javascript files are checked by default; you'll almost certainly want to change that, because the default
is `public/javascripts/**/*.js` which means all Javascript files, and you probably don't want JSLint to check entire
jQuery, Prototype or whatever other libraries you use - so change this so that only your scripts are checked (you can
put multiple entries under "paths:" and "exclude_paths:")
* tweak JSLint options to enable or disable specific checks - I've set the defaults to what I believe is reasonable,
but what's reasonable for me may not be reasonable for you


## Running

To start the check, run the rake task:

    rake jslint

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

For the best effect, you should include JSLint check in your Continuous Integration build - that way, you'll get
immediate notification when you've committed JS code with errors.


## Additional options

I've added some additional options to JSLint to get rid of some warnings which I thought didn't make sense. They're all
disabled by default, but feel free to enable any or all of them if you feel abused by JSLint.

Here's a documentation for all the extra options:


### lastsemic

If set to true, this will ignore warnings about missing semicolon after a statement, if the statement is the last one in
a block or function. I've added this because I like to omit the semicolon in one-liner anonymous functions, in
situations like this:

    var ids = $$('.entry').map(function(e) { return e.id });


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


## Credits

* JSLint on Rails was created by [Jakub Suder](http://psionides.jogger.pl), licensed under MIT License
* JSLint was created by [Douglas Crockford](http://jslint.com)
