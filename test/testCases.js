module.exports = {
    testCases: function(config) {
        var cases = config.cases;
        var func = config.function;
        var that = config.object;

        test(config.title, function() {
	    
            cases.forEach(function(caseData, ix) {
	        var input = caseData[0];

	        if (!(input instanceof Array))
		    input = [input];

                var expected = caseData[1];
	        var msg = caseData[2];
	        
	        if (expected instanceof RegExp) {
		    msg || (msg = config.title+": given '"+input+"' fails with error matching "+expected);
		    throws(function() {
		        func.apply(that, input)
		    }, expected, msg);
	        }
	        else {
		    msg || (msg = config.title+": given '"+input+"' returns '"+expected+"'");
		    var output = func.apply(that, input);
		    deepEqual( output, expected, msg );
	        }
	    });
        });
    }
};