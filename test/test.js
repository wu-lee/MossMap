'use strict';
var QUnit;
if (typeof QUnit == 'undefined') // if your tests also run in the browser...
     QUnit = require('qunit-cli');

var utils = require('mossmap-utils.js');


function mkCursor() {
    var args = arguments;
    return function() {
        return Array.prototype.shift.call(args);
    }
}

function testCases(config) {
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

testCases({
    title: "mkCursor",
    function: mkCursor(1,2,3,4),
    cases: [
	[ null, 1 ],
	[ null, 2 ],
	[ null, 3 ],
	[ null, 4 ],
	[ null, undefined ],
	[ null, undefined ],
	
//	["O", /invalid grid reference letter 'O'/],
   ]
});


testCases({
    title: "nestOnto",
    function: utils.nestOnto,
    cases: [
	[
            [4, mkCursor(
                [0,0,0,0],
                [0,0,0,1],
                [0,0,1,0],
                [0,0,1,1],
                [0,1,0,0],
                [0,1,0,1],
                [0,1,1,0],
                [0,1,1,1],
                [1,0,0,0],
                [1,0,0,1],
                [1,0,1,0],
                [1,0,1,1],
                [1,1,0,0],
                [1,1,0,1],
                [1,1,1,0],
                [1,1,1,1]
            )],
            [[0,[[0,{"0":1,"1":1}],[1,{"0":1,"1":1}]]],[1,[[0,{"0":1,"1":1}],[1,{"0":1,"1":1}]]]]
        ],
	[
            [7,mkCursor(
                [0,0,0,0,0,0,0],
                [0,0,0,0,0,0,1],
                [0,0,0,0,0,1,0],
                [0,0,0,0,0,1,1],
                [0,0,0,0,1,0,0],
                [0,0,0,0,1,0,1],
                [0,0,0,0,1,1,0],
                [0,0,0,0,1,1,1],
                [0,0,0,1,0,0,0],
                [0,0,0,1,0,0,1],
                [0,0,0,1,0,1,0],
                [0,0,0,1,0,1,1],
                [0,0,0,1,1,0,0],
                [0,0,0,1,1,0,1],
                [0,0,0,1,1,1,0],
                [0,0,0,1,1,1,1]
            )],
            [[0,[[0,[[0,[[0,[[0,{"0":1,"1":1}],
                             [1,{"0":1,"1":1}]]],
                         [1,[[0,{"0":1,"1":1}],
                             [1,{"0":1,"1":1}]]]]]]]]]]
        ],
	
//	["O", /invalid grid reference letter 'O'/],
   ]
});

