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


var csvdata = 
'Taxon,GR,Tetrad,Site,Year,Recorder\n'+
'Tetraphis pellucida,SJ7967,SJ76Y,The Quinta,2002,"Smith, J; Jones, S.P."\n'+
'Hypnum cupressiforme,SJ5584,SJ58M,Oxmoor Local Nature Reserve,2013,"Jones, S.P."\n'+
'Tortula muralis,SK0297,SK09I,Tintwistle,2013,"Bloggs, J."\n'+
'Plagiothecium nemorale,SJ4844,SJ44X,Wych Brook area,1994,"Smith, J."\n'+
'Homalothecium sericeum,SJ5785,SJ58S,Moore Nature Reserve,2013,"Jones, S.P."\n'+
'Tetrad,SJ57Z,SJ57Z,Moore Nature Reserve,2013,"Jones, S.P."';

var mkRowIteratorExpected = [
    ['Taxon','GR','Tetrad','Site','Year','Recorder'],
    ['Tetraphis pellucida',
     'SJ7967',
     'SJ76Y',
     'The Quinta',
     '2002',
     'Smith, J; Jones, S.P.'],
    ['Hypnum cupressiforme',
     'SJ5584',
     'SJ58M',
     'Oxmoor Local Nature Reserve',
     '2013',
     'Jones, S.P.'],
    ['Tortula muralis',
     'SK0297',
     'SK09I',
     'Tintwistle',
     '2013',
     'Bloggs, J.'],
    ['Plagiothecium nemorale',
     'SJ4844',
     'SJ44X',
     'Wych Brook area',
     '1994',
     'Smith, J.'],
    ['Homalothecium sericeum',
     'SJ5785',
     'SJ58S',
     'Moore Nature Reserve',
     '2013',
     'Jones, S.P.'],
    ['Tetrad',
     'SJ57Z',
     'SJ57Z',
     'Moore Nature Reserve',
     '2013',
     'Jones, S.P.'],
    undefined
];

// Test opening various sources using mkRowIterator and
// mk_filtered_row_iterator
testCases({
    title: "csv2json.mkRowIterator",
    function: function(csv) {
        // make the iterator, get rows
        var iter = csv2json.mkRowIterator(csv);
        var json = [iter(), iter(), iter(), iter(), iter(), iter(), iter(), iter()];
        return json;
    },
    cases: [
        [[csvdata], mkRowIteratorExpected]
    ]
});


var mkFilteredRowIteratorExpected = [
    {'taxon':'Tetraphis pellucida',
     'gridRef':'SJ7967',
     'date':'2002',
     'recorders':['Smith, J','Jones, S.P.']},
    {'taxon':'Hypnum cupressiforme',
     'gridRef':'SJ5584',
     'date':'2013',
     'recorders':['Jones, S.P.']},
    {'taxon':'Tortula muralis',
     'gridRef':'SK0297',
     'date':'2013',
     'recorders':['Bloggs, J.']},
    {'taxon':'Plagiothecium nemorale',
     'gridRef':'SJ4844',
     'date':'1994',
     'recorders':['Smith, J.']},
    {'taxon':'Homalothecium sericeum',
     'gridRef':'SJ5785',
     'date':'2013',
     'recorders':['Jones, S.P.']},
    {'taxon':'Tetrad',
     'gridRef':'SJ57Z',
     'date':'2013',
     'recorders':['Jones, S.P.']},
    undefined
];

// Test opening various sources using mkRowIterator and
// mk_filtered_row_iterator
testCases({
    title: "csv2json.mkFilteredRowIterator",
    function: function(csv) {
        // make the iterator, get first and second row (headings)
        var iter = csv2json.mkFilteredRowIterator(csv);
        var json = [iter(), iter(), iter(), iter(), iter(), iter(), iter()];
        return json;
    },
    cases: [
        [[csvdata], mkFilteredRowIteratorExpected]
    ]
});

