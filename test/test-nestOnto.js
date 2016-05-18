'use strict';
var QUnit;
if (typeof QUnit == 'undefined') // if your tests also run in the browser...
     QUnit = require('qunit-cli');

var utils = require('mossmap-utils.js');

var testCases = require('test/testCases.js').testCases;


function mkCursor() {
    var args = arguments;
    return function() {
        return Array.prototype.shift.call(args);
    }
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

