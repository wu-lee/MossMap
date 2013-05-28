'use strict';


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
    title: "dintyToXY",
    function: dintyToXY,
    cases: [
	["A", {x: 0, y: 0}],
	["E", {x: 0, y: 4}],
	["I", {x: 1, y: 3}],
	["M", {x: 2, y: 2}],
	["R", {x: 3, y: 1}],
	["V", {x: 4, y: 0}],
	["Z", {x: 4, y: 4}],
	
	["O", /invalid grid reference letter 'O'/],
	["a", /invalid grid reference letter 'a'/],
	["z", /invalid grid reference letter 'z'/],
	["0", /invalid grid reference letter '0'/],
	[" ", /invalid grid reference letter ' '/],
	["[", /invalid grid reference letter '\['/]
   ]
});

testCases({
    title: "fghjkToXY",
    function: fghjkToXY,
    cases: [
	["V", {x: 0, y: 0}],
	["A", {x: 0, y: 4}],
	["G", {x: 1, y: 3}],
	["N", {x: 2, y: 2}],
	["T", {x: 3, y: 1}],
	["Z", {x: 4, y: 0}],
	["O", {x: 3, y: 2}],
	["E", {x: 4, y: 4}],
	
	["I", /invalid grid reference letter 'I'/],
	["a", /invalid grid reference letter 'a'/],
	["z", /invalid grid reference letter 'z'/],
	["0", /invalid grid reference letter '0'/],
	[" ", /invalid grid reference letter ' '/],
	["[", /invalid grid reference letter '\['/]
   ]
});


testCases({
    title: "osAlphaToFalseOriginCoord",
    function: osAlphaToFalseOriginCoord,
    cases: [
	[["A","A"], {x: 0, y: 4*500*1000 + 4*100*1000}],
	[["Z","Z"], {x: 4*500*1000 + 4*100*1000, y: 0}],
	[["G","T"], {x: 1*500*1000 + 3*100*1000, y: 3*500*1000 + 1*100*1000}],
	[["V","V"], {x: 0, y: 0}],
	[["N","N"], {x: 2*500*1000 + 2*100*1000, y: 2*500*1000 + 2*100*1000}],
	[["E","E"], {x: 4*500*1000 + 4*100*1000, y: 4*500*1000 + 4*100*1000}],

	[["I","O"], /invalid grid reference letter 'I'/],
	[["O","I"], /invalid grid reference letter 'I'/],
	[["o","o"], /invalid grid reference letter 'o'/],
   ]
});


testCases({
    title: "gridrefToFalseOriginCoord",
    function: gridrefToFalseOriginCoord,
    cases: [
	["VV00", {x: 0, y: 0, precision: 10000}],
	["VV0000", {x: 0, y: 0, precision: 1000}],
	["VV000000", {x: 0, y: 0, precision: 100}],
	["VV00000000", {x: 0, y: 0, precision: 10}],
	["VV0000000000", {x: 0, y: 0, precision: 1}],
	["VV000000000000", {x: 0, y: 0, precision: 0.1}],
	["EE", {x: 4*500*1000 + 4*100*1000, y: 4*500*1000 + 4*100*1000, precision: 100000}],
	["EE00", {x: 4*500*1000 + 4*100*1000, y: 4*500*1000 + 4*100*1000, precision: 10000}],
	["VV42", {x: 4*10000, y: 2*10000, precision: 10000}],
	["AB12", {x: 0*500*1000 + 1*100*1000 + 1*10000, y: 4*500*1000 + 4*100*1000 + 2*10000, precision: 10000}],
	["GH1234", {x: 1*500*1000 + 2*100*1000 + 12*1000, y: 3*500*1000 + 3*100*1000 + 34*1000, precision: 1000}],
	["NO123456", {x: 2*500*1000 + 3*100*1000 + 123*100, y: 2*500*1000 + 2*100*1000 + 456*100, precision: 100}],
	["TU12345678", {x: 3*500*1000 + 4*100*1000 + 1234*10, y: 1*500*1000 + 1*100*1000 + 5678*10, precision: 10}],
	["ZV1234567890", {x: 4*500*1000 + 0*100*1000 + 12345*1, y: 0*500*1000 + 0*100*1000 + 67890*1, precision: 1}],

	["E", /malformed grid reference: E/],
	["E6", /malformed grid reference: E6/],
	["II", /invalid grid reference letter 'I'/],
	["AAA", /malformed grid reference contains tetrad suffix with wrong numeric precision \(0/],
	["VV0", /malformed grid reference contains uneven numeric component with 1 digit/],
	["VV000", /malformed grid reference contains uneven numeric component with 3 digits/],
	["VV00000", /malformed grid reference contains uneven numeric component with 5 digits/],
	["VV0000000", /malformed grid reference contains uneven numeric component with 7 digits/],
	["VV000000000", /malformed grid reference contains uneven numeric component with 9 digits/],

   ]
});





/*

test( "dintyToIJ", function() {
    var cases = [
        [
	    "",
	    "SJ86",
	    {x: 0, y:0}
	],
    ];
    
    for(var ix = 0; ix < cases.length; ix++) {
        var gridref = cases[ix][1];
        var msg = cases[ix][0]+": "+gridref;
        var data = gridref2view(gridref);

        var expected = cases[ix][2];

        deepEqual( data, expected, msg );
    }
});
*/
/*
test( "gridref2view correctly transforms grid references", function() {
    var cases = [
        [
	    "",
	    "SJ86",
	    {x: 0, y:0}
	],
    ];
    
    for(var ix = 0; ix < cases.length; ix++) {
        var gridref = cases[ix][1];
        var msg = cases[ix][0]+": "+gridref;
        var data = gridref2view(gridref);

        var expected = cases[ix][2];

        deepEqual( data, expected, msg );
    }
});
*/