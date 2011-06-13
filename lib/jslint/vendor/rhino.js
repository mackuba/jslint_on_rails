// based on rhino.js by Douglas Crockford from www.jslint.com

(function (args) {

    function pluralize(amount, word) {
        return amount + " " + word + ((amount == 1) ? "" : "s");
    }

    // parse options from a comma-separated string into a hash
    var optionFields = args[0].split("&");
    var options = {};
    for (var i = 0; i < optionFields.length; i++) {
        var equalsSignIndex = optionFields[i].lastIndexOf("=");
        if (equalsSignIndex != -1) {
            var key = optionFields[i].substr(0, equalsSignIndex);
            var value = optionFields[i].substr(equalsSignIndex + 1);
            options[key] = eval(value);
        }
    }
    if (options.predef) {
      options.predef = options.predef.split(",");
    }

    var totalErrors = 0;
    var LINT = this.JSLINT || this.JSHINT;

    // test every file
    for (var f = 1; f < args.length; f++) {
        java.lang.System.out.print("checking " + args[f] + "... ");

        var input = readFile(args[f]);
        if (!input) {
            print("Error: couldn't open file.");
        } else if (!LINT(input, options)) {
            print(pluralize(LINT.errors.length, "error") + ":\n");
            totalErrors += LINT.errors.length;
            for (var i = 0; i < LINT.errors.length; i += 1) {
                var e = LINT.errors[i];
                if (e) {
                    print('Lint at line ' + e.line + ' character ' + e.character + ': ' + e.reason);
                    print((e.evidence || '').replace(/^\s*(\S*(\s+\S+)*)\s*$/, "$1"));
                    print('');
                }
            }
        } else {
            print("OK");
        }
    }

    if (totalErrors === 0) {
        print("\nNo JS errors found.");
    } else {
        print("\nFound " + pluralize(totalErrors, "error") + ".");
        quit(1);
    }

}(arguments));
