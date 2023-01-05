var dinty = require('dinty');
var papa = require('papaparse/papaparse.js');

/** Defines what we keep, and name mappings thereof.
 * An ordered list of paired key-value items. Keys can be
 * either field names, or arrays thereof.  Values are either 
 * field names, or functions mapping the whole row of data into 
 * an array containing the required field value (or values)
 */
var heading_map = [
    'taxon', 'taxon',
    'gridRef', 'gr',
    
    // Dates are formatted as either '', 'YYYY', 'YYYYMM', or 'YYYYMMDD'
    // depending on the precision
    'date', function(row) {
        function norm(val) {
            return val == null? '' : // null or undefined
            val == '#VALUE!'? '' : // spreadsheet error
            String(Math.floor(val)); // normalised number
        }
        function zpad(width, num) {
            return "0000".substring(num.length)+num;
        }
        var y = norm(row.year);
        var m = norm(row.month);
        var d = norm(row.day);

        if (y.length && m.length && d)
            return [zpad(4, y)+zpad(2, m)+zpad(2, d)];

        if (y.length && m.length)
            return [zpad(4, y)+zpad(2, m)];

        if (y.length)
            return [zpad(4, y)];

        return [''];
    },

    // Converts a delimited list of recorders into an array ref
    // Trims whitespace.
    'recorders', function(row) {
        function nonEmpty(str) {
            return str.length > 0;
        }
        function trim(str) {
            return str.trim();
        }
        var recorder = row.recorder;

        if (recorder == null)
            return '';

        return [recorder.split(';').map(trim).filter(nonEmpty)];
    },
];

function filterRow(row, trace) {
    // Ignore undefined gridrefs
    if (!row.gridRef) {
        trace("discarding as undefined grid ref");
        return;
    }

    var gridRef = row.gridRef;

    // trim whitespace
    gridRef.replace(/^\s+/, '');
    gridRef.replace(/\s+$/, '');
    gridRef = gridRef.toUpperCase();

    var len = gridRef.length;

    // Check for empties
    if (len == 0) {
        throw new Error("empty grid ref "+gridRef);
    }

    if (len < 5) {            
        trace("discarding as too coarse: "+gridRef);
        return;
    }
    
    // Check this gridref is valid, and convert to tetrad
    // precision
    row.tetrad = dinty.gridrefToTetrad(gridRef);
    row.gridRef = gridRef;

    return row;
}


/** Returns a subref which iterates over CSV data, returning an
 * array-ref of data with no filtering (including the heading line),
 * and no interpretation of the rows.
 * Returns an empty list when there is no more data.
 */
function mkRowIterator(csv) {
    var iterator;
    var ix = 0;
    var results = papa.parse(csv, {
    });
    var ary = results.data;
    results = null;

    return function() {
        if (ix >= ary.length)
            return;

        return ary[ix++];
    };
}

/** Returns a function which iterates over the CSV data, returning a
 * list of valid, normalised data items.  You won't see the
 * headings, and returned items are taxon, grid_ref, date, and recorder.
 */
function mkFilteredRowIterator(ary) {
    var trace = function() {}; // FIXME or get trace function
    
    var iterator = mkRowIterator(ary, trace);

    var headings = iterator();
    if (!headings || Object.keys(headings).length == 0)
        throw new Error("No headings found");

    // Normalise by stripping non alpha-numeric chars, and lower-casing.
    // Some additional special-case mapping too.
    var count = {};
    function norm(heading) {
        heading = heading.replace(/[\W_]+/, '');
        heading = heading.toLowerCase();
        if (heading == 'recorders')
            heading = 'recorder';
        else
            heading = heading.replace(/^gridref.*/, 'gr');
        count[heading]++;
        return heading;
    }
    function zeroCount(heading) {
        return !(heading in count) || count[heading] < 0;
    }
    function multiCount(heading) {
        return heading in count && count[heading] > 1;
    }
    
    headings = headings.map(norm);

    // Warn about missing and duplicate headings
    // Note, some of these count may be undefined
    var missing = ['taxon', 'gr', 'recorder', 'year'].filter(zeroCount)

    if (missing.length)
        throw new Error("These mandatory headings are missing even after "+
                        "normalising the input headings: "+missing.join(', '));
    
    var dupes = [
        'taxon',
        'gr',
        'recorder',
        'year',
        'month',
        'day'
    ].filter(multiCount);

    if (dupes.length)
        trace("these headings are duplicated after normalising, "+
              "so you may not be getting the result you expect: "+
              dupes.join(', '))
    
    return function() {
        while (true) {
            var csv_row_ref = iterator();
            var csv_row = {};
            if (csv_row_ref == null)
                break;

            // map row into map with headings as keys
            for(var ix = 0; ix < csv_row_ref.length; ix += 1) {
                csv_row[headings[ix]] = csv_row_ref[ix];
            }

            var row = [];
            for(var ix = 0; ix < heading_map.length; ix += 2) {
                var fields = heading_map[ix];
                var mapper = heading_map[ix+1];

                if (!(fields instanceof Array))
                    fields = [fields] 

                var value = mapper;
                if (!(mapper instanceof Function))
                    mapper = function(it) { return [it[value]] };

                var values = mapper(csv_row);
                for(var jx = 0; jx < fields.length; jx += 1) {
                    row[fields[jx]] = values[jx];
                }
            }

            // Optionally discard data points
            row = filterRow(row, trace);
            if (!row)
                continue;

            return {
                taxon: row.taxon, 
                gridRef: row.gridRef,
                date: row.date,
                recorders: row.recorders,
            };
        }

        // If we get here we ran out of data
        return;
    };
}

module.exports = {
    filterRow: filterRow,
    mkRowIterator: mkRowIterator,
    mkFilteredRowIterator: mkFilteredRowIterator,
};
