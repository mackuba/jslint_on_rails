# JSLint on Rails

**JSLint on Rails** is a Rails plugin which lets you run the [JSLint JavaScript code checker](http://jslint.com) on
your Javascript code easily.

## Installation

First, make sure you have **Java** available on your machine - it's required because JSLint is itself written in
JavaScript, and is run using the [Rhino](http://www.mozilla.org/rhino) JavaScript engine (which is written in Java).
Any decent version of Java will do (and by decent I mean 5.0 or later).

Next, install the plugin:

    ./script/plugin install git://github.com/psionides/jslint_on_rails.git

This will create a sample `jslint.yml` config file in your config directory. In this file, you can:

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

    rake jslint paths=public/javascripts/models/*.js,public/javascripts/lib/*.js exclude_paths=public/javascripts/jquery.js,public/javascripts/jquery-ui.js

For the best effect, you should include JSLint check in your Continuous Integration build - that way, you'll get
immediate notification when you've committed JS code with errors.

## Credits

* JSLint on Rails was created by [Jakub Suder](http://psionides.jogger.pl), licensed under MIT License
* JSLint was created by [Douglas Crockford](http://jslint.com)
