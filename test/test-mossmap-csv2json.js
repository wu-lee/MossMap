'use strict';
var QUnit;
if (typeof QUnit == 'undefined') // if your tests also run in the browser...
     QUnit = require('qunit-cli');

var csv2json = require('mossmap-csv2json.js');
var testCases = require('test/testCases.js').testCases;

function noop() {}

testCases({
    title: "csv2json.filterRow",
    function: csv2json.filterRow,
    cases: [

        [ [{gridRef: 'SJ'}, noop], undefined ],
        [ [{gridRef: 'SJ12'}, noop], undefined ],

        [ [{gridRef: 'SJ1234'}, noop],  {gridRef: 'SJ1234', tetrad: 'SJ13H'} ],
        [ [{gridRef: 'SJ5083'}, noop],  {gridRef: 'SJ5083', tetrad: 'SJ58B'} ],
        [ [{gridRef: 'SJ509829'}, noop], {gridRef: 'SJ509829', tetrad: 'SJ58B'} ],
        [ [{gridRef: 'SJ510831'}, noop], {gridRef: 'SJ510831', tetrad: 'SJ58B'} ],
        [ [{gridRef: 'SJ5182'}, noop],  {gridRef: 'SJ5182', tetrad: 'SJ58B'} ],
    ]
});

